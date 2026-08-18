export function countStreak(dates: string[], todayIso: string): number {
  const todayDate = new Date(todayIso);
  const yesterdayDate = new Date(todayDate);
  yesterdayDate.setDate(todayDate.getDate() - 1);

  const dayBeforeYesterdayDate = new Date(todayDate);
  dayBeforeYesterdayDate.setDate(todayDate.getDate() - 2);

  const today = todayDate.toISOString().slice(0, 10);
  const yesterday = yesterdayDate.toISOString().slice(0, 10);
  const dayBeforeYesterday = dayBeforeYesterdayDate.toISOString().slice(0, 10);

  if (dates.includes(today) && dates.includes(yesterday)) {
    return 2;
  } else if (
    dates.includes(dayBeforeYesterday) &&
    dates.includes(yesterday) &&
    !dates.includes(today)
  ) {
    return 2;
  } else if (dates.includes(today)) {
    return 1;
  } else {
    return 0;
  }
}
