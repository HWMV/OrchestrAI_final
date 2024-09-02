import asyncio
import logging
import re
from typing import List, Optional
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from langchain_openai import OpenAI
from pydantic import BaseModel
from utils.tasks_orch import Tasks, Task
from utils.agent_orch import AgentRegistry
from crewai import Crew, Process, Task as CrewTask
import os
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.DEBUG, filename='app.log', filemode='w', format='%(name)s - %(levelname)s - %(message)s')

app = FastAPI(debug=True)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# os.environ["OPENAI_API_KEY"] = 

@app.middleware("http")
async def add_cors_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["Access-Control-Allow-Methods"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "*"
    return response

@app.options("/agents")
async def options_agents():
    return JSONResponse(content={"message": "OK"}, headers={"Access-Control-Allow-Methods": "GET, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Accept"})

@app.get("/agents")
def get_agents():
    agents = AgentRegistry.get_all_agents()
    logging.debug(f"Registered agents: {agents}")
    return JSONResponse(content={"agents": agents}, headers={"Access-Control-Allow-Methods": "GET, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Accept"})

@app.get("/agents/{agent_name}")
def get_agent_details(agent_name: str):
    logging.debug(f"Requested agent name: {agent_name}")
    agent_class = AgentRegistry.get_agent(agent_name)
    if agent_class:
        try:
            agent = agent_class()
            logging.debug(f"Found agent: {agent_name}")
            return JSONResponse(
                content={"name": agent_name, "role": agent.role, "goal": agent.goal, "backstory": agent.backstory},
                headers={"Access-Control-Allow-Methods": "GET, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Accept"}
            )
        except ValueError as e:
            logging.error(e)
            raise HTTPException(status_code=404, detail="에이전트를 찾을 수 없습니다.")
    else:
        logging.debug(f"Agent not found: {agent_name}")
        raise HTTPException(status_code=404, detail="에이전트를 찾을 수 없습니다.")

@app.options("/agents/{agent_name}")
async def options_agent_details():
    return JSONResponse(content={"message": "OK"}, headers={"Access-Control-Allow-Methods": "GET, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Accept"})

@app.options("/execute-crew")
async def options_execute_crew():
    return JSONResponse(content={"message": "OK"}, headers={"Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Accept"})

class AgentInput(BaseModel):
    agent_name: str
    user_input: str
    depends_on: Optional[List[str]] = []  

class CrewInput(BaseModel):
    agents: List[AgentInput]
    user_input: str

@app.post("/execute-crew")
async def execute_crew(crew_input: CrewInput):
    try:
        agents = []
        tasks = []
        previous_outputs = {}
        agent_name_to_instance = {}
        agent_name_to_task = {}
        
        for agent_input in crew_input.agents:
            agent_class = AgentRegistry.get_agent(agent_input.agent_name)
            if agent_class:
                agent_instance = agent_class()
                logging.debug(f"Agent instance created: {agent_instance}")
                agents.append(agent_instance)
                agent_name_to_instance[agent_input.agent_name] = agent_instance
                
                # 이전 Task의 출력을 입력으로 사용
                previous_output = None
                if agent_input.depends_on:
                    previous_output = previous_outputs.get(agent_input.depends_on[0])
                
                task = Tasks.get_task_for_agent(agent_instance, user_input=agent_input.user_input, previous_output=previous_output)
                
                logging.debug(f"Task created: {task}")
                tasks.append(task)
                agent_name_to_task[agent_input.agent_name] = task
            else:
                raise ValueError(f"Agent not found: {agent_input.agent_name}")

        # 의존성 설정
        for agent_input in crew_input.agents:
            if agent_input.depends_on:
                current_task = agent_name_to_task[agent_input.agent_name]
                context_tasks = [agent_name_to_task[dep] for dep in agent_input.depends_on if dep in agent_name_to_task]
                # 새로운 Task 인스턴스 생성 시 context를 사용하여 의존성 설정
                new_task = Task(
                    description=current_task.description,
                    agent=current_task.agent,
                    expected_output=current_task.expected_output,
                    context=context_tasks  # 의존성을 context로 설정
                )
                agent_name_to_task[agent_input.agent_name] = new_task
                tasks[tasks.index(current_task)] = new_task

        manager_llm = OpenAI(temperature=0.7)

        crew = Crew(
            agents=agents,
            tasks=tasks,
            verbose=True,
            process=Process.hierarchical, 
            manager_llm=manager_llm
        )
        logging.debug(f"Crew created: {crew}")

        result = crew.kickoff()

        logging.debug(f"Result structure: {dir(result)}")

        # CrewOutput 객체를 딕셔너리로 변환
        result_dict = {
            "raw": result.raw if hasattr(result, 'raw') else str(result),
            "tasks_output": [],
            "final_output": str(result),
            "generated_image_url": None
        }

        # tasks_output 처리
        if hasattr(result, 'tasks_output'):
            for task_output in result.tasks_output:
                task_dict = {}
                if hasattr(task_output, 'task'):
                    task_dict["task"] = {
                        "description": task_output.task.description if hasattr(task_output.task, 'description') else "No description",
                        "expected_output": task_output.task.expected_output if hasattr(task_output.task, 'expected_output') else "No expected output"
                    }
                if hasattr(task_output, 'output'):
                    task_dict["output"] = task_output.output
                    # 이전 출력 저장
                    if hasattr(task_output.task, 'agent'):
                        agent_name = next((name for name, agent in agent_name_to_instance.items() if agent == task_output.task.agent), None)
                        if agent_name:
                            previous_outputs[agent_name] = task_output.output
                    
                    # DALL-E 이미지 URL 추출
                    if task_output.task.agent.__class__.__name__ == "WebtoonArtist":
                        url_match = re.search(r'https?://\S+', task_output.output)
                        if url_match:
                            result_dict["generated_image_url"] = url_match.group(0)
                
                if hasattr(task_output, 'agent'):
                    task_dict["agent"] = {
                        "role": task_output.agent.role if hasattr(task_output.agent, 'role') else "No role",
                        "goal": task_output.agent.goal if hasattr(task_output.agent, 'goal') else "No goal"
                    }
                result_dict["tasks_output"].append(task_dict)

        # token_usage 처리
        if hasattr(result, 'token_usage'):
            if isinstance(result.token_usage, dict):
                result_dict["token_usage"] = result.token_usage
            elif hasattr(result.token_usage, '__dict__'):
                result_dict["token_usage"] = result.token_usage.__dict__
            else:
                result_dict["token_usage"] = str(result.token_usage)

        return JSONResponse(
            content={"result": result_dict},
            headers={"Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Accept"}
        )
    except Exception as e:
        logging.error(f"Error in execute_crew: {e}")
        logging.error(f"Error type: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error occurred while creating crew: {str(e)}")

    
if __name__ == "__main__":#
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)