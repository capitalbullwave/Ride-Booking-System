import { PUBLIC_API, apiFetch } from "@/lib/api";
import { getAiFeatureFallback } from "@/lib/ai-feature-fallbacks";

export type AiChatRole = "user" | "assistant";

export type AiChatMessage = {
  role: AiChatRole;
  content: string;
};

type AiChatResponse = {
  reply: string;
};

export async function sendAiChatMessage(
  message: string,
  history: AiChatMessage[] = []
): Promise<string> {
  try {
    const data = await apiFetch<AiChatResponse>(
      `${PUBLIC_API}/ai-chat`,
      {
        method: "POST",
        body: JSON.stringify({
          message,
          history: history.slice(-8).map((item) => ({
            role: item.role,
            content: item.content,
          })),
        }),
      },
      "Could not reach Bullwave Assistant"
    );
    return data.reply?.trim() || getAiFeatureFallback(message);
  } catch {
    // Local Backend/.env OpenAI is preferred; if staging/API is down, still answer.
    return getAiFeatureFallback(message);
  }
}
