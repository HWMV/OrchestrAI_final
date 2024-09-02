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
            description=f"""Conduct comprehensive research on various aspects of novel writing based on the following user input:

            User Input: {user_input}

            Your research should include:
            1. Characters: Develop potential character profiles and backstories.
            2. Settings: Research and describe possible settings for the story.
            3. Plot Ideas: Generate potential plot points and story arcs.
            4. Themes: Identify and explore possible themes relevant to the user's input.
            5. Genre-specific elements: Investigate common tropes and conventions of the genre implied by the user's input.

            Organize the information into clear categories and provide a structured report.""",
            agent=agent,
            expected_output="""A structured research report with the following components:
            1. Detailed character profiles with potential backstories
            2. Descriptions of possible settings, including historical or cultural context if relevant
            3. A list of potential plot points and story arcs
            4. Analysis of themes that could be explored in the story
            5. Genre-specific elements that could be incorporated
            6. A summary of how these elements align with the user's original input""",
        )

    @staticmethod
    def scenario_development(agent: Any, user_input: str, previous_output: Optional[str] = None) -> Task:
        return Task(
            description=f"""Using the structured research provided by the Novel Researcher (if available) and the following user input, create and refine storylines, character arcs, and plot structures.

            User Input: {user_input}
            Previous Research: {previous_output if previous_output else "No previous research available"}

            Your task includes:
            1. Main Plot: Develop a cohesive main plot that incorporates key elements from the available inputs.
            2. Character Arcs: Create detailed character arcs for the main characters.
            3. Subplots: Develop relevant subplots that enhance the main story.
            4. Scene Outline: Provide a high-level outline of key scenes.
            5. Thematic Development: Show how the identified themes will be explored throughout the story.

            Focus on creating a narrative that stays true to the available inputs while crafting an engaging story.""",
            agent=agent,
            expected_output="""A well-structured scenario document that includes:
            1. A detailed main plot outline
            2. Character arcs for each main character
            3. Descriptions of relevant subplots
            4. A scene-by-scene outline of the story
            5. Explanation of how themes are woven into the narrative
            6. Justification for major plot points and character decisions based on the available inputs""",
        )

    @staticmethod
    def webtoon_creation(agent: Any, user_input: str, previous_output: Optional[str] = None) -> Task:
        return Task(
            description=f"""Transform the available inputs into a visual webtoon format. Break down the story into panels, focusing on key visual elements and transitions.

            User Input: {user_input}
            Previous Scenario: {previous_output if previous_output else "No previous scenario available"}

            Your task includes:
            1. Panel Breakdown: Divide the story into a series of panels, each representing a key moment or scene.
            2. Visual Descriptions: For each panel, provide a detailed description of what should be depicted.
            3. Dialogue Placement: Indicate where dialogue or narration should be placed in each panel.
            4. Transition Notes: Describe how transitions between panels should be handled.
            5. Style Suggestions: Provide notes on the visual style that would best suit the story.

            Ensure that your storyboard captures the essence of the available inputs while adapting it to a visual medium.""",
            agent=agent,
            expected_output="""A complete webtoon storyboard that includes:
            1. A panel-by-panel breakdown of the story
            2. Detailed visual descriptions for each panel
            3. Dialogue and narration placement
            4. Notes on panel transitions and pacing
            5. Suggestions for overall visual style
            6. Explanation of how the visual elements enhance the story and reflect the available inputs""",
        )

    @staticmethod
    def webtoon_drawing(agent: Any, user_input: str, previous_output: str) -> Task:
        return Task(
            description=f"""Create a single image webtoon panel based on the provided storyboard and previous results.

            User Input: {user_input}
            Storyboard: {previous_output}

            Your task includes:
            1. Analyze the storyboard and previous results to understand the context and style of the webtoon.
            2. Choose a key moment or scene from the storyboard to illustrate.
            3. Create a detailed description of the image to be generated, including:
                - Characters and their expressions
                - Setting and background elements
                - Action or key visual elements
                - Color scheme and overall mood
            4. Ensure that the image captures the essence of the story and aligns with the webtoon's style.

            Your description will be used as a prompt for DALL-E image generation.""",
            agent=agent,
            expected_output="""A detailed description for a single webtoon panel image that includes:
            1. A vivid depiction of the chosen scene or moment
            2. Character details including poses, expressions, and clothing
            3. Background and setting elements
            4. Color palette and lighting suggestions
            5. Any text or dialogue to be included in the panel
            6. Explanation of how this panel represents a key moment in the story""",
        )