import { ColorScheme, StartScreenPrompt, ThemeOption } from "@openai/chatkit";

const rawWorkflowId = process.env.NEXT_PUBLIC_CHATKIT_WORKFLOW_ID;
export const WORKFLOW_ID = rawWorkflowId?.trim() ?? "";

if (typeof console !== "undefined") {
  console.log("[config] NEXT_PUBLIC_CHATKIT_WORKFLOW_ID", rawWorkflowId);
  console.log("[config] WORKFLOW_ID", WORKFLOW_ID);
}

export const CREATE_SESSION_ENDPOINT = "/api/create-session";

export const STARTER_PROMPTS: StartScreenPrompt[] = [
  {
    label: "What can you do?",
    prompt: "What can you do?",
    icon: "circle-question",
  },
];

export const PLACEHOLDER_INPUT = "Ask anything...";

export const GREETING = "How can I help you today?";

export const getThemeConfig = (theme: ColorScheme): ThemeOption => ({
  color: {
    grayscale: {
      hue: 220,
      tint: 6,
      shade: theme === "dark" ? -1 : -4,
    },
    accent: {
      primary: theme === "dark" ? "#f1f5f9" : "#0f172a",
      level: 1,
    },
  },
  radius: "round",
  // Add other theme options here
  // chatkit.studio/playground to explore config options
});
