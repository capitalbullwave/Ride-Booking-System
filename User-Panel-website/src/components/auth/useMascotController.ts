"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import type {
  MascotControllerState,
  MascotExpression,
  MascotFocus,
  MascotMode,
  PupilOffset,
} from "./mascot-types";

const PUPIL_MAX = 5.5;
const BLINK_MIN_MS = 3000;
const BLINK_MAX_MS = 5000;

function clampPupil(dx: number, dy: number, maxRadius: number): PupilOffset {
  const dist = Math.sqrt(dx * dx + dy * dy);
  if (dist <= maxRadius) return { x: dx, y: dy };
  const scale = maxRadius / dist;
  return { x: dx * scale, y: dy * scale };
}

function getElementCenter(el: HTMLElement | null) {
  if (!el) return null;
  const rect = el.getBoundingClientRect();
  return { x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 };
}

function getPupilsTowardPoint(
  mascotRect: DOMRect,
  target: { x: number; y: number },
  leftEye: { x: number; y: number },
  rightEye: { x: number; y: number }
) {
  const scaleX = mascotRect.width / 320;
  const scaleY = mascotRect.height / 380;

  const toPupil = (eyeLocal: { x: number; y: number }) => {
    const eyeScreenX = mascotRect.left + eyeLocal.x * scaleX;
    const eyeScreenY = mascotRect.top + eyeLocal.y * scaleY;
    return clampPupil(target.x - eyeScreenX, target.y - eyeScreenY, PUPIL_MAX);
  };

  return {
    left: toPupil(leftEye),
    right: toPupil(rightEye),
  };
}

const LEFT_EYE = { x: 105, y: 168 };
const RIGHT_EYE = { x: 215, y: 168 };
const SHY_PUPILS: PupilOffset = { x: -4.5, y: -1.5 };

interface UseMascotControllerOptions {
  phoneRef: React.RefObject<HTMLInputElement | null>;
  passwordRef: React.RefObject<HTMLInputElement | null>;
  mascotRef: React.RefObject<HTMLDivElement | null>;
  nameRef?: React.RefObject<HTMLInputElement | null>;
  emailRef?: React.RefObject<HTMLInputElement | null>;
}

export function useMascotController({
  phoneRef,
  passwordRef,
  mascotRef,
  nameRef,
  emailRef,
}: UseMascotControllerOptions) {
  const [expression, setExpression] = useState<MascotExpression>("neutral");
  const [focus, setFocus] = useState<MascotFocus>("none");
  const [mode, setMode] = useState<MascotMode>("track");
  const [isBlinking, setIsBlinking] = useState(false);
  const [isShaking, setIsShaking] = useState(false);
  const [leftPupil, setLeftPupil] = useState<PupilOffset>({ x: 0, y: 0 });
  const [rightPupil, setRightPupil] = useState<PupilOffset>({ x: 0, y: 0 });
  const [headTilt, setHeadTilt] = useState(0);
  const [showHands, setShowHands] = useState(false);
  const [showRedGlow, setShowRedGlow] = useState(false);
  const [celebrate, setCelebrate] = useState(false);

  const pointerRef = useRef({ x: 0, y: 0 });
  const rafRef = useRef<number | null>(null);

  const updatePupils = useCallback(() => {
    const mascotEl = mascotRef.current;
    if (!mascotEl) return;

    const rect = mascotEl.getBoundingClientRect();
    if (rect.width === 0) return;

    if (mode === "shy") {
      setLeftPupil(SHY_PUPILS);
      setRightPupil(SHY_PUPILS);
      return;
    }

    let target = pointerRef.current;

    if (mode === "lookAt") {
      if (focus === "phone") {
        const center = getElementCenter(phoneRef.current);
        if (center) target = center;
      } else if (focus === "name" && nameRef) {
        const center = getElementCenter(nameRef.current);
        if (center) target = center;
      } else if (focus === "email" && emailRef) {
        const center = getElementCenter(emailRef.current);
        if (center) target = center;
      }
    }

    const pupils = getPupilsTowardPoint(rect, target, LEFT_EYE, RIGHT_EYE);
    setLeftPupil(pupils.left);
    setRightPupil(pupils.right);
  }, [phoneRef, nameRef, emailRef, focus, mascotRef, mode]);

  const schedulePupilUpdate = useCallback(() => {
    if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);
    rafRef.current = requestAnimationFrame(() => {
      updatePupils();
      rafRef.current = null;
    });
  }, [updatePupils]);

  useEffect(() => {
    const handlePointer = (e: PointerEvent) => {
      pointerRef.current = { x: e.clientX, y: e.clientY };
      if (mode === "track") schedulePupilUpdate();
    };

    window.addEventListener("pointermove", handlePointer, { passive: true });
    window.addEventListener("pointerdown", handlePointer, { passive: true });
    return () => window.removeEventListener("pointermove", handlePointer);
  }, [mode, schedulePupilUpdate]);

  useEffect(() => {
    schedulePupilUpdate();
  }, [mode, focus, schedulePupilUpdate]);

  useEffect(() => {
    let timeoutId: ReturnType<typeof setTimeout>;
    let blinkTimeoutId: ReturnType<typeof setTimeout>;

    const scheduleBlink = () => {
      const delay =
        BLINK_MIN_MS + Math.random() * (BLINK_MAX_MS - BLINK_MIN_MS);
      timeoutId = setTimeout(() => {
        setIsBlinking(true);
        blinkTimeoutId = setTimeout(() => {
          setIsBlinking(false);
          scheduleBlink();
        }, 140);
      }, delay);
    };

    scheduleBlink();
    return () => {
      clearTimeout(timeoutId);
      clearTimeout(blinkTimeoutId);
    };
  }, []);

  const handlePhoneFocus = useCallback(() => {
    setFocus("phone");
    setMode("lookAt");
    setShowHands(false);
    setExpression("neutral");
    schedulePupilUpdate();
  }, [schedulePupilUpdate]);

  const handleNameFocus = useCallback(() => {
    setFocus("name");
    setMode("lookAt");
    setShowHands(false);
    setExpression("neutral");
    schedulePupilUpdate();
  }, [schedulePupilUpdate]);

  const handleEmailFocus = useCallback(() => {
    setFocus("email");
    setMode("lookAt");
    setShowHands(false);
    setExpression("neutral");
    schedulePupilUpdate();
  }, [schedulePupilUpdate]);

  const handlePasswordFocus = useCallback(() => {
    setFocus("password");
    setMode("shy");
    setShowHands(true);
    setExpression("shy");
  }, []);

  const handleFieldBlur = useCallback(() => {
    window.requestAnimationFrame(() => {
      const active = document.activeElement;
      const focusedRefs = [phoneRef.current, passwordRef.current, nameRef?.current, emailRef?.current];
      if (focusedRefs.some((el) => el && active === el)) return;

      setFocus("none");
      setMode("track");
      setShowHands(false);
      setExpression((current) => (current === "shy" ? "neutral" : current));
      schedulePupilUpdate();
    });
  }, [phoneRef, passwordRef, nameRef, emailRef, schedulePupilUpdate]);

  const triggerInvalidPhone = useCallback(() => {
    setExpression("confused");
    setHeadTilt(9);
    setMode("track");
    setShowHands(false);
    window.setTimeout(() => setHeadTilt(0), 900);
  }, []);

  const triggerWrongPassword = useCallback(() => {
    setExpression("sad");
    setShowRedGlow(true);
    setIsShaking(true);
    setMode("shy");
    setShowHands(false);
    window.setTimeout(() => setIsShaking(false), 700);
    window.setTimeout(() => setShowRedGlow(false), 2200);
  }, []);

  const triggerSuccess = useCallback(() => {
    setExpression("happy");
    setCelebrate(true);
    setShowHands(false);
    setMode("track");
    setHeadTilt(0);
  }, []);

  const resetExpression = useCallback(() => {
    if (expression === "confused" || expression === "sad") {
      setExpression("neutral");
      setHeadTilt(0);
    }
  }, [expression]);

  const state: MascotControllerState = {
    expression,
    focus,
    mode,
    isBlinking,
    isShaking,
    leftPupil,
    rightPupil,
    headTilt,
    showHands,
    showRedGlow,
    celebrate,
  };

  return {
    state,
    handleNameFocus,
    handleEmailFocus,
    handlePhoneFocus,
    handlePasswordFocus,
    handleFieldBlur,
    triggerInvalidPhone,
    triggerWrongPassword,
    triggerSuccess,
    resetExpression,
  };
}
