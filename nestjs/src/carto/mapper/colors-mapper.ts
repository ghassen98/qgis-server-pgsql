import { isWithinInterval } from 'date-fns';

type DescItem = {
  description: string;
  rpa: string;
  timeSlots?: { start: string; end: string }[];
  days?: string[];
  validityPeriod?: {
    start: { month: string | null; day: number | null };
    end: { month: string | null; day: number | null };
  };
};

type MappedDesc = {
  description: string;
  rpa: string;
  color: 'red' | 'green';
};

const monthMap: Record<string, number> = {
  JANVIER: 0,
  FEVRIER: 1,
  MARS: 2,
  AVRIL: 3,
  MAI: 4,
  JUIN: 5,
  JUILLET: 6,
  AOUT: 7,
  SEPTEMBRE: 8,
  OCTOBRE: 9,
  NOVEMBRE: 10,
  DECEMBRE: 11,
};

function isCurrentDateWithinPeriod(desc: DescItem): boolean {
  const now = new Date();

  let withinPeriod = true;
  if (desc.validityPeriod) {
    const { start, end } = desc.validityPeriod;
    if (start.month !== null && start.day !== null && end.month !== null && end.day !== null) {
      const startDate = new Date(now.getFullYear(), monthMap[start.month], start.day);
      const endDate = new Date(now.getFullYear(), monthMap[end.month], end.day);
      withinPeriod = isWithinInterval(now, { start: startDate, end: endDate });
    }
  }

  let withinDays = true;
  if (desc.days && desc.days.length > 0) {
    const today = now.toLocaleString('fr-FR', { weekday: 'long' });
    withinDays = desc.days.includes(today);
  }

  let withinTimeSlot = true;
  if (desc.timeSlots && desc.timeSlots.length > 0) {
    const nowTime = now.getHours() * 60 + now.getMinutes();
    withinTimeSlot = desc.timeSlots.some(({ start, end }) => {
      const parseTime = (time: string) => {
        const [hourStr, minuteStr] = time.includes('h') ? time.split('h') : [time, '0'];
        const hour = Number(hourStr);
        const minute = minuteStr ? Number(minuteStr) : 0;
        return hour * 60 + minute;
      };

      const startTime = parseTime(start);
      const endTime = parseTime(end);
      return nowTime >= startTime && nowTime <= endTime;
    });
  }

  return withinPeriod && withinDays && withinTimeSlot;
}

export function mapDesc(descArray: DescItem[]): MappedDesc[] {
  return descArray.map(({ description, rpa, ...rest }) => {
    let color: 'red' | 'green' = 'green';
    if (description.includes('\\A EN TOUT TEMPS') || description.includes('\\P EN TOUT TEMPS')) {
      color = 'red';
    } else if (isCurrentDateWithinPeriod({ description, rpa, ...rest })) {
      color = 'red';
    }

    return { description, rpa, color };
  });
}