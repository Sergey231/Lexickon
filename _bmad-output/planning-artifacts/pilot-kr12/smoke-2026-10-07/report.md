# Пилот KR-12: отчёт (smoke-2026-10-07)

Модель JEV: jev-1.13.0

## general (10 слов)

- Точное совпадение уровня: **50%** (окно 80% … 1−20/N определено только при N ≥ 100; это пробный прогон)
- Совпадение с точностью до одного уровня: 100%
- Расхождений для слепой оценки: 5 (критерий: не менее 20)
- Стабильность повторов: **100%** (критерий: не менее 95%)
- Средний сдвиг JEV относительно частоты: -0.30 уровня

| слово | Zipf | частота | JEV | conf | повторы |
|---|---|---|---|---|---|
| thank | 5.432 | very_high | very_high | 0.52 | very_high very_high very_high |
| poor | 5.250 | very_high | high ≠ | 0.74 | high high high |
| learning | 4.964 | high | medium ≠ | 0.51 | medium medium medium |
| wellness | 4.196 | high | medium ≠ | 0.87 | medium medium medium |
| filament | 3.700 | medium | limited ≠ | 0.89 | limited limited limited |
| astounding | 3.327 | medium | medium | 0.69 | medium medium medium |
| filigree | 2.343 | limited | limited | 0.71 | limited limited limited |
| unmake | 2.057 | limited | limited | 0.84 | limited limited limited |
| pseudomembranous | 1.618 | low | low | 0.71 | low low low |
| cuke | 1.330 | low | limited ≠ | 0.43 | limited limited limited |

## programming (10 слов)

- Точное совпадение уровня: **30%** (окно 80% … 1−20/N определено только при N ≥ 100; это пробный прогон)
- Совпадение с точностью до одного уровня: 80%
- Расхождений для слепой оценки: 7 (критерий: не менее 20)
- Стабильность повторов: **100%** (критерий: не менее 95%)
- Средний сдвиг JEV относительно частоты: -0.50 уровня

| слово | Zipf | частота | JEV | conf | повторы |
|---|---|---|---|---|---|
| text | 5.800 | very_high | very_high | 0.32 | very_high very_high very_high |
| think | 5.469 | very_high | medium ≠ | 0.34 | medium medium medium |
| meet | 4.776 | high | medium ≠ | 0.37 | medium medium medium |
| shareable | 4.386 | high | limited ≠ | 0.68 | limited limited limited |
| contour | 3.054 | medium | limited ≠ | 0.77 | limited limited limited |
| colorization | 3.003 | medium | limited ≠ | 0.74 | limited limited limited |
| reprint | 2.990 | limited | limited | 0.72 | limited limited limited |
| delicate | 2.729 | limited | limited | 0.79 | limited limited limited |
| slant | 2.021 | low | limited ≠ | 0.73 | limited limited limited |
| hike | 2.021 | low | limited ≠ | 0.58 | limited limited limited |

Задержка: медиана 962 мс, p95 1198 мс (60 вызовов)
