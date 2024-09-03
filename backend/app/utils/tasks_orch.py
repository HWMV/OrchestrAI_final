import logging
from crewai import Task as CrewTask
from typing import Any, List, Optional, Dict

class Task(CrewTask):
    user_input: Optional[str] = None
    previous_output: Optional[str] = None

    def set_user_input(self, user_input: str):
        self.user_input = user_input

    def set_previous_output(self, output: str):
        self.previous_output = output

    async def execute(self, agent: Any, context: Dict[str, Any] = None, tools: List[Any] = None) -> str:
        if context is None:
            context = {}
        if self.user_input:
            context['user_input'] = self.user_input
        if self.previous_output:
            context['previous_output'] = self.previous_output
        result = await super().execute(agent, context=context)
        return str(result)

class Tasks:
    @staticmethod
    def get_task_for_agent(agent: Any, user_input: Optional[str] = None, previous_output: Optional[str] = None) -> Task:
        task_methods = {
            "NovelResearcher": Tasks.novel_research,
            "ScenarioEditor": Tasks.scenario_development,
            "WebtoonEditor": Tasks.webtoon_creation,
            "WebtoonArtist": Tasks.webtoon_drawing,
        }
        
        task_method = task_methods.get(agent.__class__.__name__)
        if task_method:
            task = task_method(agent, user_input, previous_output)
            logging.debug(f"Task created for agent {agent.__class__.__name__}: {task}")
            return task
        else:
            task = Task(
                description=f"Perform the role of {agent.__class__.__name__} based on the available input.",
                agent=agent,
                expected_output=f"A detailed output based on the {agent.__class__.__name__}'s expertise, incorporating available inputs and addressing the requirements.",
            )
            if user_input:
                task.set_user_input(user_input)
            if previous_output:
                task.set_previous_output(previous_output)
            logging.debug(f"Default task created for agent {agent.__class__.__name__}: {task}")
            return task

    @staticmethod
    def novel_research(agent: Any, user_input: str, previous_output: Optional[str] = None) -> Task:
        return Task(
            description=f"""Conduct comprehensive research on various aspects of novel writing based on the following input:

            User Input: {user_input}
            Previous Output: {previous_output if previous_output else "No previous output available"}

            Your task includes:
            1. Analyze the user input and previous output (if available) to understand the context.
            2. Research character development, plot structures, and world-building techniques relevant to the given context.
            3. Investigate genre-specific elements and tropes that could enhance the story.
            4. Compile a list of potential historical or cultural references that could add depth to the narrative.
            5. Organize your findings into clear categories for easy reference by other team members.

            Provide a structured research report that can be easily used by writers and editors in subsequent steps.""",
            agent=agent,
            expected_output="""A comprehensive research report including:
            1. Character development insights
            2. Plot structure analysis
            3. World-building techniques
            4. Genre-specific elements and tropes
            5. Historical and cultural references
            6. Any additional insights that could benefit the story development process"""
        )

    @staticmethod
    def scenario_development(agent: Any, user_input: str, previous_output: Optional[str] = None) -> Task:
        return Task(
            description=f"""Create a detailed scenario based on the following inputs:

            User Input: {user_input}
            Previous Research: {previous_output if previous_output else "No previous research available"}

            Your task includes:
            1. Analyze the user input and previous research to understand the story context.
            2. Develop a coherent main plot that incorporates key elements from the research.
            3. Create detailed character profiles and arcs for main characters.
            4. Design relevant subplots that enhance the main story.
            5. Outline key scenes and turning points in the narrative.
            6. Incorporate thematic elements identified in the research.

            Produce a well-structured scenario document that can be easily translated into a visual format by the Webtoon Editor.""",
            agent=agent,
            expected_output="""A detailed scenario document including:
            1. Main plot outline
            2. Character profiles and arcs
            3. Subplot descriptions
            4. Key scene outlines
            5. Thematic elements integration
            6. Any additional story elements that could enhance the narrative"""
        )

    @staticmethod
    def webtoon_creation(agent: Any, user_input: str, previous_output: Optional[str] = None) -> Task:
        return Task(
            description=f"""Transform the provided scenario into a visual webtoon format:

            User Input: {user_input}
            Previous Scenario: {previous_output if previous_output else "No previous scenario available"}

            Your task includes:
            1. Analyze the user input and previous scenario to understand the story and its visual potential.
            2. Break down the story into a series of panels, each representing a key moment or scene.
            3. Provide detailed visual descriptions for each panel, including character poses, expressions, and background elements.
            4. Indicate dialogue and narration placement within the panels.
            5. Describe transitions between panels and overall pacing of the story.
            6. Suggest an overall visual style that best suits the story's tone and genre.

            Create a comprehensive webtoon storyboard that can be used by the Webtoon Artist to generate the final images.""",
            agent=agent,
            expected_output="""A detailed webtoon storyboard including:
            1. Panel-by-panel breakdown of the story
            2. Visual descriptions for each panel
            3. Dialogue and narration placement
            4. Transition and pacing notes
            5. Overall visual style suggestions
            6. Any additional visual elements that could enhance the storytelling"""
        )

    @staticmethod
    def webtoon_drawing(agent: Any, user_input: str, previous_output: str) -> Task:
        return Task(
            description=f"""Create a single image webtoon panel based on the provided storyboard:

            User Input: {user_input}
            Storyboard: {previous_output}

            Your task includes:
            1. Carefully analyze the storyboard and user input to understand the scene's context and style.
            2. Select a key moment or scene from the storyboard to illustrate.
            3. Create a detailed description of the image to be generated, including:
                - Character details (poses, expressions, clothing)
                - Setting and background elements
                - Action or key visual elements
                - Color scheme and overall mood
            4. Ensure that the image captures the essence of the story and aligns with the webtoon's style.
            5. Provide clear instructions for DALL-E image generation.

            Your description will be used as a prompt for DALL-E image generation, so be as specific and detailed as possible.""",
            agent=agent,
            expected_output="""A comprehensive image description for DALL-E, including:
            1. Detailed scene layout
            2. Character descriptions
            3. Background and setting details
            4. Color palette and lighting
            5. Any text or special effects to be included
            6. Explanation of how this image represents a key moment in the story"""
        )