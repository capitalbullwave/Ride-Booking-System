export function helpSectionPath(sectionId: string) {
  return `/profile/help/${sectionId}`;
}

export function helpArticlePath(sectionId: string, articleId: string) {
  return `/profile/help/${sectionId}/${articleId}`;
}

export const HELP_MESSAGES_PATH = "/profile/help/messages";
