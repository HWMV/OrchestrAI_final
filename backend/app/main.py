import json
import logging
import re
from crewai import Crew
from typing import List, Optional
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
# import httpx
import httpx
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

openai_api_key = os.getenv("OPENAI_API_KEY")

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
                
                previous_output = None
                if agent_input.depends_on:
                    previous_output = previous_outputs.get(agent_input.depends_on[0])
                
                # WebtoonArtist에게 이전 Agent의 결과 전달
                if agent_input.agent_name == "WebtoonArtist" and previous_output:
                    task = Tasks.get_task_for_agent(agent_instance, user_input=previous_output, previous_output=previous_output)
                else:
                    task = Tasks.get_task_for_agent(agent_instance, user_input=agent_input.user_input, previous_output=previous_output)
                
                if agent_input == crew_input.agents[-1]:
                    task.expected_output = '{"generated_image_url": "string", "dalle_prompt": "string"}'
                                
                logging.debug(f"Task created: {task}")
                tasks.append(task)
                agent_name_to_task[agent_input.agent_name] = task
                previous_outputs[agent_input.agent_name] = task
            else:
                raise ValueError(f"Agent not found: {agent_input.agent_name}")

        manager_llm = OpenAI(temperature=0.7)

        crew = Crew(
            agents=agents,
            tasks=tasks,
            verbose=True,
            process=Process.hierarchical,
            manager_llm=manager_llm,
        )
        logging.debug(f"Crew created: {crew}")

        result = crew.kickoff()

        logging.info(f"Crew kickoff result: {result}")
        logging.info(f"Result type: {type(result)}")

        # result dict 구성 요소 (출력하고 싶은 부분이 있으면 여기에 로직 추가)
        if isinstance(result, dict):
            result_dict = result
        elif isinstance(result, str):
            try:
                result_dict = json.loads(result)
            except json.JSONDecodeError:
                result_dict = {"raw_result": result}
        else:
            result_dict = {"raw_result": str(result)}

        # URL 추출 (전체 URL 유지)
        if "generated_image_url" not in result_dict:
            url_match = re.search(r'(https?://\S+)', str(result))
            if url_match:
                full_url = url_match.group(1)
                result_dict["generated_image_url"] = full_url

        logging.info(f"Extracted URL: {result_dict.get('generated_image_url')}")
        logging.info(f"Processed result: {json.dumps(result_dict, indent=2)}")

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
    uvicorn.run(app, host="0.0.0.0", port=8080)