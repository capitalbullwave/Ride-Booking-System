export type MascotExpression =
  | "neutral"
  | "happy"
  | "confused"
  | "sad"
  | "shy";

export type MascotFocus = "none" | "name" | "phone" | "email" | "password";

export type MascotMode = "track" | "lookAt" | "shy";

export interface PupilOffset {
  x: number;
  y: number;
}

export interface MascotControllerState {
  expression: MascotExpression;
  focus: MascotFocus;
  mode: MascotMode;
  isBlinking: boolean;
  isShaking: boolean;
  leftPupil: PupilOffset;
  rightPupil: PupilOffset;
  headTilt: number;
  showHands: boolean;
  showRedGlow: boolean;
  celebrate: boolean;
}
