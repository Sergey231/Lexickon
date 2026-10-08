# Пилот фраз (домен разработки): отчёт (phrases-programming)

Модель JEV: jev-1.13.0; фраз: 150; повторов на фразу: 3–3
Критерии: приложение PRD §A.3.

| Критерий | Значение | Итог |
|---|---|---|
| (а) Порядок: Spearman JEV − Spearman правила ≥ 0.05 | 0.389 − 0.281 = +0.107 | пройден |
| (а) Совпадение точки (калибровка по долям) ≥ 60% и выше правила | JEV 45%, правило 42% | **не пройден** |
| (а) Грубые ошибки (высокая ↔ низкая) ≤ 10% | 11% | **не пройден** |
| (б) AUC «устойчивое выражение» ≥ 0.80 | 0.705 | **не пройден** |
| Стабильность (а) ≥ 95% | 94% | **не пройден** |
| Стабильность (б) ≥ 95% | 98% | пройден |

Справочно: совпадение по собственным уровням JEV (без калибровки) 43%, грубые ошибки без калибровки 9%.
Задержка: медиана 601 мс, p95 826 мс.

## Матрица (эталон × JEV после калибровки)

| эталон \ JEV | low | medium | high |
|---|---|---|---|
| low | 25 | 17 | 8 |
| medium | 17 | 17 | 16 |
| high | 8 | 16 | 26 |

## Устойчивость: средняя вероятность «да» по клеткам

| частота | устойчивые | свободные |
|---|---|---|
| high | 0.67 | 0.43 |
| medium | 0.58 | 0.47 |
| low | 0.60 | 0.37 |

## Фразы

| фраза | Zipf | частота | JEV | правило | NPMI | класс | «да» |
|---|---|---|---|---|---|---|---|
| command line | 5.58 | high | high | high | 0.69 | fixed | 0.93 |
| strict mode | 4.94 | high | high | medium | 0.72 | fixed | 0.93 |
| figure out | 4.83 | high | high | medium | 0.68 | fixed | 0.78 |
| side effects | 4.79 | high | medium ≠ | medium | 0.74 | fixed | 0.90 |
| new function | 4.65 | high | high | high | 0.19 | free | 0.33 |
| test function | 4.63 | high | high | high | 0.22 | free | 0.78 |
| rust code | 4.59 | high | medium ≠ | high | 0.25 | free | 0.52 |
| low level | 4.56 | high | medium ≠ | medium | 0.67 | fixed | 0.72 |
| case insensitive | 4.54 | high | high | low | 0.65 | fixed | 0.88 |
| home directory | 4.51 | high | high | medium | 0.54 | fixed | 0.89 |
| use redux | 4.50 | high | low ≠ | high | 0.19 | free | 0.36 |
| maximum number | 4.50 | high | high | medium | 0.53 | fixed | 0.36 |
| used instead | 4.47 | high | medium ≠ | high | 0.24 | free | 0.21 |
| high level | 4.45 | high | high | medium | 0.60 | fixed | 0.76 |
| new array | 4.43 | high | medium ≠ | high | 0.25 | free | 0.22 |
| data directory | 4.42 | high | high | medium | 0.23 | free | 0.65 |
| implemented in | 4.42 | high | high | high | 0.20 | free | 0.57 |
| used on | 4.41 | high | medium ≠ | high | 0.07 | free | 0.24 |
| denial of service | 4.41 | high | medium ≠ | low | 0.76 | fixed | 0.95 |
| cannot use | 4.40 | high | medium ≠ | low | 0.22 | free | 0.15 |
| query string | 4.37 | high | high | high | 0.28 | free | 0.93 |
| easier to read | 4.33 | high | medium ≠ | low | 0.52 | fixed | 0.18 |
| curly braces | 4.32 | high | high | low | 0.86 | fixed | 0.78 |
| line number | 4.31 | high | high | high | 0.26 | free | 0.78 |
| more specific | 4.27 | high | medium ≠ | high | 0.25 | free | 0.14 |
| need to set | 4.27 | high | high | high | 0.19 | free | 0.29 |
| best practice | 4.27 | high | high | low | 0.59 | fixed | 0.90 |
| like the following | 4.25 | high | high | high | 0.18 | free | 0.41 |
| other way | 4.22 | high | low ≠ | high | 0.17 | free | 0.23 |
| virtual machine | 4.21 | high | high | medium | 0.57 | fixed | 0.94 |
| automatically detect | 4.21 | high | high | medium | 0.54 | fixed | 0.46 |
| left hand | 4.20 | high | low ≠ | medium | 0.57 | fixed | 0.17 |
| prepared statement | 4.18 | high | low ≠ | medium | 0.57 | fixed | 0.66 |
| add support | 4.17 | high | high | high | 0.25 | free | 0.65 |
| working as expected | 4.17 | high | high | high | 0.52 | fixed | 0.50 |
| input and output | 4.16 | high | high | high | 0.51 | fixed | 0.82 |
| exist on | 4.13 | high | low ≠ | high | 0.21 | free | 0.25 |
| wait until | 4.10 | high | medium ≠ | medium | 0.55 | fixed | 0.27 |
| use cargo | 4.10 | high | low ≠ | high | 0.06 | free | 0.20 |
| open up | 4.08 | high | medium ≠ | high | 0.28 | free | 0.53 |
| master branch | 4.08 | high | high | low | 0.54 | fixed | 0.91 |
| take precedence | 4.08 | high | low ≠ | medium | 0.53 | fixed | 0.66 |
| install docker | 4.07 | high | high | medium | 0.24 | free | 0.47 |
| spread syntax | 4.07 | high | medium ≠ | low | 0.53 | fixed | 0.89 |
| new directory | 4.04 | high | high | high | 0.15 | free | 0.30 |
| saved in | 4.03 | high | medium ≠ | medium | 0.20 | free | 0.19 |
| news article | 4.02 | high | low ≠ | medium | 0.73 | fixed | 0.32 |
| way of doing | 4.01 | high | medium ≠ | low | 0.52 | fixed | 0.20 |
| new commit | 4.01 | high | high | high | 0.20 | free | 0.50 |
| turn on | 4.01 | high | medium ≠ | medium | 0.22 | free | 0.76 |
| static analysis | 3.99 | medium | high ≠ | medium | 0.52 | fixed | 0.94 |
| bare repository | 3.95 | medium | low ≠ | low | 0.54 | fixed | 0.93 |
| non existent | 3.95 | medium | low ≠ | low | 0.64 | fixed | 0.36 |
| insertion order | 3.93 | medium | low ≠ | low | 0.53 | fixed | 0.78 |
| state field | 3.90 | medium | medium | high | 0.17 | free | 0.54 |
| works the same | 3.90 | medium | medium | high | 0.20 | free | 0.23 |
| merge commit | 3.87 | medium | high ≠ | high | 0.28 | free | 0.92 |
| take into account | 3.86 | medium | medium | medium | 0.55 | fixed | 0.76 |
| prune unused | 3.84 | medium | low ≠ | low | 0.64 | fixed | 0.35 |
| execute method | 3.84 | medium | high ≠ | high | 0.25 | free | 0.65 |
| internal server error | 3.83 | medium | high ≠ | medium | 0.50 | fixed | 0.92 |
| little endian | 3.82 | medium | low ≠ | low | 0.69 | fixed | 0.95 |
| signal is sent | 3.73 | medium | medium | low | 0.64 | fixed | 0.26 |
| use any other | 3.73 | medium | low ≠ | high | 0.15 | free | 0.11 |
| dollar sign | 3.70 | medium | medium | low | 0.65 | fixed | 0.61 |
| looping through | 3.69 | medium | high ≠ | medium | 0.53 | fixed | 0.55 |
| add multiple | 3.69 | medium | medium | high | 0.13 | free | 0.16 |
| standard error stream | 3.68 | medium | high ≠ | medium | 0.58 | fixed | 0.91 |
| test flag | 3.67 | medium | medium | high | 0.16 | free | 0.80 |
| days ago | 3.65 | medium | medium | low | 0.60 | fixed | 0.17 |
| following statement | 3.64 | medium | low ≠ | high | 0.17 | free | 0.32 |
| floating point value | 3.63 | medium | high ≠ | medium | 0.27 | free | 0.86 |
| favorite color | 3.61 | medium | low ≠ | low | 0.57 | fixed | 0.17 |
| applied on | 3.60 | medium | low ≠ | high | 0.12 | free | 0.24 |
| startup and shutdown | 3.60 | medium | high ≠ | low | 0.76 | fixed | 0.71 |
| handle error | 3.58 | medium | high ≠ | high | 0.12 | free | 0.70 |
| tell react | 3.58 | medium | low ≠ | medium | 0.26 | free | 0.19 |
| per thread | 3.58 | medium | medium | medium | 0.28 | free | 0.57 |
| slightly differently | 3.56 | medium | low ≠ | low | 0.57 | fixed | 0.09 |
| connection is closed | 3.55 | medium | high ≠ | low | 0.54 | fixed | 0.55 |
| absolute or relative | 3.54 | medium | medium | medium | 0.68 | fixed | 0.58 |
| condition is met | 3.54 | medium | high ≠ | low | 0.69 | fixed | 0.51 |
| licensed under | 3.54 | medium | medium | medium | 0.59 | fixed | 0.76 |
| find the first | 3.53 | medium | high ≠ | high | 0.18 | free | 0.17 |
| nested object | 3.53 | medium | high ≠ | medium | 0.17 | free | 0.80 |
| attempt to create | 3.51 | medium | low ≠ | medium | 0.24 | free | 0.15 |
| without worrying | 3.50 | medium | low ≠ | low | 0.52 | fixed | 0.11 |
| special character | 3.47 | medium | high ≠ | medium | 0.29 | free | 0.78 |
| available memory | 3.47 | medium | high ≠ | high | 0.17 | free | 0.64 |
| release manager | 3.46 | medium | low ≠ | medium | 0.29 | free | 0.85 |
| auto incrementing | 3.46 | medium | medium | low | 0.59 | fixed | 0.79 |
| using the first | 3.45 | medium | medium | low | 0.02 | free | 0.11 |
| lower and upper | 3.45 | medium | medium | low | 0.68 | fixed | 0.37 |
| turn it off | 3.44 | medium | medium | medium | 0.56 | fixed | 0.56 |
| infinite recursion | 3.44 | medium | high ≠ | low | 0.62 | fixed | 0.86 |
| operate in | 3.43 | medium | medium | medium | 0.12 | free | 0.51 |
| new model | 3.43 | medium | medium | high | 0.05 | free | 0.35 |
| library reference | 3.41 | medium | low ≠ | high | 0.13 | free | 0.53 |
| sequence object | 3.41 | medium | low ≠ | medium | 0.14 | free | 0.55 |
| see the next | 3.41 | medium | low ≠ | high | 0.12 | free | 0.14 |
| userland proxy | 3.39 | low | low | low | 0.63 | fixed | 0.80 |
| brute force | 3.39 | low | medium ≠ | low | 0.69 | fixed | 0.93 |
| double or single | 3.38 | low | low | medium | 0.56 | fixed | 0.38 |
| look more | 3.37 | low | low | high | 0.06 | free | 0.09 |
| semantically equivalent | 3.37 | low | medium ≠ | low | 0.55 | fixed | 0.63 |
| progress indicator | 3.37 | low | medium ≠ | low | 0.57 | fixed | 0.84 |
| call without | 3.36 | low | low | high | 0.06 | free | 0.16 |
| relatively expensive | 3.35 | low | low | low | 0.58 | fixed | 0.11 |
| sooner or later | 3.34 | low | low | low | 0.57 | fixed | 0.69 |
| lowercase letter | 3.32 | low | high ≠ | low | 0.55 | fixed | 0.58 |
| public or private | 3.32 | low | high ≠ | medium | 0.63 | fixed | 0.61 |
| case block | 3.32 | low | low | high | 0.10 | free | 0.50 |
| pseudo tty | 3.27 | low | medium ≠ | low | 0.60 | fixed | 0.94 |
| level set | 3.27 | low | low | high | 0.05 | free | 0.81 |
| function you provide | 3.26 | low | low | high | 0.26 | free | 0.15 |
| opening bracket | 3.24 | low | high ≠ | medium | 0.56 | fixed | 0.67 |
| meaning of life | 3.24 | low | low | low | 0.56 | fixed | 0.26 |
| unless specified | 3.23 | low | medium ≠ | medium | 0.18 | free | 0.48 |
| strict equality operator | 3.23 | low | high ≠ | low | 0.51 | fixed | 0.85 |
| struct or union | 3.23 | low | medium ≠ | medium | 0.60 | fixed | 0.71 |
| used the default | 3.23 | low | high ≠ | high | 0.01 | free | 0.26 |
| scattered throughout | 3.21 | low | low | low | 0.69 | fixed | 0.26 |
| scale factor | 3.21 | low | low | low | 0.59 | fixed | 0.88 |
| command to see | 3.21 | low | low | high | 0.12 | free | 0.17 |
| window text | 3.21 | low | medium ≠ | medium | 0.21 | free | 0.47 |
| designed to support | 3.21 | low | medium ≠ | medium | 0.28 | free | 0.22 |
| reduce the probability | 3.20 | low | low | low | 0.62 | fixed | 0.20 |
| anything more | 3.20 | low | low | medium | 0.09 | free | 0.11 |
| policy enforcement | 3.17 | low | low | low | 0.53 | fixed | 0.79 |
| value is added | 3.17 | low | low | low | 0.18 | free | 0.63 |
| generate new | 3.16 | low | medium ≠ | high | 0.09 | free | 0.23 |
| post mortem | 3.15 | low | medium ≠ | low | 0.57 | fixed | 0.93 |
| generally safe | 3.14 | low | low | medium | 0.29 | free | 0.21 |
| escaped by doubling | 3.14 | low | low | medium | 0.73 | fixed | 0.51 |
| key relationship | 3.14 | low | low | low | 0.29 | free | 0.60 |
| straight forward | 3.09 | low | medium ≠ | low | 0.53 | fixed | 0.53 |
| multiple build | 3.07 | low | medium ≠ | high | 0.02 | free | 0.39 |
| match the version | 3.06 | low | medium ≠ | high | 0.16 | free | 0.29 |
| five million | 3.03 | low | low | low | 0.52 | fixed | 0.10 |
| diff program | 3.03 | low | high ≠ | medium | 0.16 | free | 0.76 |
| using the id | 3.03 | low | low | low | 0.07 | free | 0.28 |
| antivirus software | 3.00 | low | low | low | 0.61 | fixed | 0.81 |
| protecting against | 2.95 | low | medium ≠ | medium | 0.53 | fixed | 0.27 |
| loop statement | 2.95 | low | high ≠ | high | 0.10 | free | 0.73 |
| enterprise grade | 2.93 | low | low | low | 0.68 | fixed | 0.84 |
| immediately call | 2.93 | low | low | medium | 0.12 | free | 0.12 |
| found in section | 2.90 | low | medium ≠ | low | 0.23 | free | 0.18 |
| define the property | 2.90 | low | medium ≠ | high | 0.21 | free | 0.26 |
| added directly | 2.87 | low | medium ≠ | medium | 0.08 | free | 0.22 |
| call signature | 2.87 | low | high ≠ | medium | 0.12 | free | 0.88 |
