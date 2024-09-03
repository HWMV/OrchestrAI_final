import os
import requests
import logging

# 로깅 설정
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

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