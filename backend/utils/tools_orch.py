# from ..tools.search_tools import SearchTools
import os
from crewai_tools import DallETool, SerperDevTool
from fastapi import logger
from pydantic import BaseModel
from langchain.tools import BaseTool
import requests  # BaseTool을 임포트

class Tool(BaseTool):  # BaseTool을 상속받아 Tool 클래스를 정의
    name: str
    description: str

    def _run(self, *args, **kwargs):
        # 여기에 구체적인 구현을 추가합니다.
        return f"Running tool: {self.name} with args: {args} and kwargs: {kwargs}"

    async def _arun(self, *args, **kwargs):
        # 여기에 비동기 구현을 추가합니다.
        return f"Running tool asynchronously: {self.name} with args: {args} and kwargs: {kwargs}"

class DALLEImageGenerator:
    def __init__(self):
        self.api_key = os.environ.get('OPENAI_API_KEY')
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY not found in environment variables")

    def generate_image(self, prompt, size="1024x1024", model="dall-e-3"):
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }

        data = {
            "prompt": prompt,
            "n": 1,
            "size": size,
            "model": model
        }

        try:
            logger.info(f"Sending request to DALL-E API with prompt: {prompt}")
            response = requests.post(
                "https://api.openai.com/v1/images/generations",
                headers=headers,
                json=data,
                timeout=120
            )
            logger.info(f"DALL-E API response status code: {response.status_code}")
            response.raise_for_status()

            result = response.json()['data'][0]['url']
            logger.info(f"Successfully generated image: {result}")
            return result
        except requests.exceptions.RequestException as e:
            logger.error(f"Error generating image: {e}")
            if e.response:
                logger.error(f"Response content: {e.response.content}")
            raise

class Tools:

    @staticmethod
    def internet_search(query: str) -> str:
        serper_tool = SerperDevTool(
            country="kr",
            locale="ko",
            location="Seoul, Seoul, South Korea",
            n_results=5
        )
        return serper_tool.run(search_query=query)
    
    # @staticmethod
    # def dalle_image_generation(prompt: str) -> str:
    #     dalle_tool = DallETool(model="dall-e-3",
    #                             size="1024x1024",
    #                             quality="standard",
    #                             n=1)
    #     result = dalle_tool.run(prompt)
    #     if isinstance(result, str):
    #         return f"Image generated with prompt: {prompt}\nResult: {result}"
    #     else:
    #         return f"Image generated with prompt: {prompt}\nResult: [Image data not displayable]"

    # 내가 직접 만든 DALL-E Tool
    @staticmethod
    def dalle_image_generation(prompt: str) -> str:
        dalle_generator = DALLEImageGenerator()
        result = dalle_generator.generate_image(prompt)
        return f"Image generated with prompt: {prompt}\nResult: {result}"




