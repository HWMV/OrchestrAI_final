import asyncio
import logging
import time
from typing import List, Dict, Any
from crewai import Agent as CrewAgent
from textwrap import dedent
import os
from dotenv import load_dotenv
from fastapi import logger
from pydantic import BaseModel
from utils.tasks_orch import Tasks
from utils.tools_orch import Tool, Tools
from tools.dall_e import DALLEImageGenerator

load_dotenv()

# 로깅 설정
logging.basicConfig(level=logging.DEBUG, filename='app.log', filemode='w', format='%(name)s - %(levelname)s - %(message)s')

class AgentRegistry:
    _agents = {}

    @classmethod
    def register(cls, agent_class):
        cls._agents[agent_class.__name__] = agent_class
        logging.debug(f"Registered agent: {agent_class.__name__}")

    @classmethod
    def get_agent(cls, agent_name):
        agent = cls._agents.get(agent_name)
        logging.debug(f"Getting agent: {agent_name}, Found: {agent is not None}")
        return agent

    @classmethod
    def get_all_agents(cls):
        agents = list(cls._agents.keys())
        logging.debug(f"All registered agents: {agents}")
        return agents

@AgentRegistry.register
class NovelResearcher(CrewAgent):
    def __init__(self):
        super().__init__(
            role='Novel Researcher',
            goal='Conduct thorough research for novel writing and provide a structured summary',
            backstory=dedent("""
                You are an experienced researcher with a passion for literature.
                Your keen eye for details allows you to uncover interesting facts and stories.
                You excel at organizing information in a clear, structured format that can be easily used by writers and editors.
            """),
            tools=[Tool(name="Internet Search", func=Tools.internet_search, description="Search the internet for information")],
            verbose=True,
            max_iter=3,
        )

    async def execute_task(self, task: Any, context: Dict[str, Any] = None, **kwargs) -> str:
        result = await super().execute_task(task, context=context, **kwargs)
        structured_result = self._structure_research(result)
        
        # 도구 사용 로직 추가
        for tool in self.tools:
            if tool.name == "Internet Search":
                search_result = tool.func("Novel writing techniques")
                logging.debug(f"Search result: {search_result}")
        
        return structured_result

    def _structure_research(self, research: str) -> str:
        return f"Structured Research:\n\n{research}\n\nEnd of Research Summary"

@AgentRegistry.register
class ScenarioEditor(CrewAgent):
    def __init__(self):
        super().__init__(
            role='Scenario Editor',
            goal='Develop engaging and consistent storylines based on research',
            backstory=dedent("""
                You are a skilled scenario editor with years of experience in creating compelling narratives.
                Your ability to craft complex plots and develop characters is unparalleled.
                You excel at taking research and turning it into a cohesive, engaging story outline.
            """),
            tools=[],
            verbose=True,
            max_iter=3,
        )

    async def execute_task(self, task: Any, context: Dict[str, Any] = None, **kwargs) -> str:
        result = await super().execute_task(task, context=context, **kwargs)
        story_outline = self._create_story_outline(result)
        return story_outline

    def _create_story_outline(self, scenario: str) -> str:
        # Here you would implement logic to create a structured story outline
        return f"Story Outline:\n\n{scenario}\n\nEnd of Story Outline"

@AgentRegistry.register
class WebtoonEditor(CrewAgent):
    def __init__(self):
        super().__init__(
            role='Webtoon Editor',
            goal='Adapt story outlines into visually appealing webtoon format',
            backstory=dedent("""
                You are a creative webtoon editor with a strong background in visual storytelling.
                You excel at transforming written narratives into engaging visual sequences for webtoons.
                Your expertise lies in breaking down story outlines into compelling panel-by-panel storyboards.
            """),
            tools=[],  # Tool 제거
            verbose=True,
        )

    def execute_task(self, task: Any, context: Dict[str, Any] = None, tools: List[Any] = None) -> str:
        result = super().execute_task(task, context=context, tools=tools)
        storyboard = self._create_storyboard(result)
        return storyboard

    def _create_storyboard(self, story_outline: str) -> str:
        return f"Webtoon Storyboard:\n\n{story_outline}\n\nEnd of Storyboard"

@AgentRegistry.register
class WebtoonArtist(CrewAgent):
    def __init__(self):
        super().__init__(
            role='Webtoon Artist',
            goal='Create visually stunning webtoon panels based on the provided storyboard',
            backstory=dedent("""
                You are a talented webtoon artist with a keen eye for visual storytelling.
                Your ability to bring stories to life through vivid illustrations is unparalleled.
                You excel at interpreting storyboards and creating captivating webtoon panels.
            """),
            tools=[Tool(name="DALL-E Image Generation", func=self.generate_dalle_image, description="Generate images using DALL-E")],
            verbose=True,
            max_iter=1,
        )
        self._dalle_generator = None

    @property
    def dalle_generator(self):
        if self._dalle_generator is None:
            self._dalle_generator = DALLEImageGenerator()
        return self._dalle_generator

    def generate_dalle_image(self, prompt, max_retries=3, delay=2):
        for attempt in range(max_retries):
            try:
                logging.info(f"Attempting to generate DALL-E image (attempt {attempt + 1}/{max_retries})")
                image_url = self.dalle_generator.generate_image(prompt)
                if image_url:
                    logging.info(f"Successfully generated DALL-E image: {image_url}")
                    return image_url
            except Exception as e:
                logging.error(f"Error generating image (attempt {attempt + 1}/{max_retries}): {str(e)}")
            
            if attempt < max_retries - 1:
                logging.info(f"Waiting {delay} seconds before next attempt")
                time.sleep(delay)
        
        logging.error(f"Failed to generate image after {max_retries} attempts")
        return None

    def execute_task(self, task: Any, context: Dict[str, Any] = None, tools: List[Any] = None) -> str:
        if not os.getenv("OPENAI_API_KEY"):
            raise ValueError("OpenAI API key not found. Please check your environment variables.")
        
        logging.info("WebtoonArtist executing task")
        dalle_prompt = super().execute_task(task, context=context, tools=tools)
        logging.info(f"Generated DALL-E prompt: {dalle_prompt}")
        
        image_url = self.generate_dalle_image(dalle_prompt)
        
        if image_url:
            result = f"Generated webtoon panel image: {image_url}\n\nDALL-E Prompt Used:\n{dalle_prompt}"
        else:
            result = f"Failed to generate image. DALL-E Prompt Used:\n{dalle_prompt}"
        
        logging.info(f"WebtoonArtist task result: {result}")
        return result