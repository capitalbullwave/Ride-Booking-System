export function LoginBackgroundDecor() {
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden" aria-hidden>
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-secondary/20 via-background to-background" />
      <div className="absolute -left-24 top-20 h-72 w-72 rounded-full bg-secondary/25 blur-3xl" />
      <div className="absolute -right-16 bottom-1/4 h-64 w-64 rounded-full bg-primary/5 blur-3xl" />
      <div className="wavego-dot-grid absolute inset-0 opacity-20" />
    </div>
  );
}
