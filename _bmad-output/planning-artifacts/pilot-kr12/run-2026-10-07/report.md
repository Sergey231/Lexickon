# Пилот KR-12: отчёт (run-2026-10-07)

Модель JEV: jev-1.13.0
Эталон general: Lemma Atlas 1.0.0 (data/core/artifacts/core_frequency_index.json)
Эталон programming: Lemma Atlas 0.1.0 (data/domains/programming/artifacts/domain_frequency_index.json)

## general (200 слов)

- Точное совпадение уровня: **34%** (критерий: окно 80% … 90%)
- Совпадение с точностью до одного уровня: 83%
- Расхождений для слепой оценки: 133 (критерий: не менее 20)
- Стабильность повторов: **95%** (критерий: не менее 95%)
- Средний сдвиг JEV относительно частоты: -0.56 уровня

| слово | Zipf | частота | JEV | conf | повторы |
|---|---|---|---|---|---|
| know | 6.346 | very_high | very_high | 0.93 | very_high very_high very_high |
| then | 6.067 | very_high | very_high | 0.56 | very_high high very_high |
| give | 6.033 | very_high | very_high | 0.91 | very_high very_high very_high |
| tell | 5.966 | very_high | very_high | 0.78 | very_high very_high very_high |
| group | 5.835 | very_high | high ≠ | 0.72 | high high high |
| however | 5.750 | very_high | medium ≠ | 0.65 | medium medium medium |
| turn | 5.654 | very_high | very_high | 0.57 | very_high very_high very_high |
| care | 5.646 | very_high | high ≠ | 0.60 | high high high |
| full | 5.555 | very_high | high ≠ | 0.69 | high high high |
| performance | 5.554 | very_high | medium ≠ | 0.82 | medium medium medium |
| clinical | 5.507 | very_high | medium ≠ | 0.61 | medium medium medium |
| ensure | 5.493 | very_high | medium ≠ | 0.79 | medium medium medium |
| money | 5.491 | very_high | very_high | 0.63 | very_high very_high very_high |
| cause | 5.487 | very_high | medium ≠ | 0.56 | medium high high |
| indicate | 5.465 | very_high | medium ≠ | 0.82 | medium medium medium |
| structure | 5.351 | very_high | medium ≠ | 0.77 | medium medium medium |
| choose | 5.337 | very_high | high ≠ | 0.69 | high high high |
| influence | 5.335 | very_high | medium ≠ | 0.77 | medium medium medium |
| relationship | 5.327 | very_high | high ≠ | 0.75 | high high high |
| enhance | 5.324 | very_high | medium ≠ | 0.82 | medium medium medium |
| track | 5.302 | very_high | medium ≠ | 0.59 | medium medium medium |
| manage | 5.265 | very_high | high ≠ | 0.78 | high high high |
| complex | 5.245 | very_high | medium ≠ | 0.73 | medium medium medium |
| previous | 5.243 | very_high | medium ≠ | 0.75 | medium medium medium |
| achieve | 5.237 | very_high | medium ≠ | 0.84 | medium medium medium |
| train | 5.229 | very_high | high ≠ | 0.62 | high high high |
| hope | 5.225 | very_high | high ≠ | 0.62 | high high high |
| mechanism | 5.194 | very_high | medium ≠ | 0.64 | medium medium medium |
| brand | 5.162 | very_high | high ≠ | 0.59 | high high high |
| village | 5.156 | very_high | medium ≠ | 0.78 | medium medium medium |
| highly | 5.145 | very_high | medium ≠ | 0.77 | medium medium medium |
| expand | 5.137 | very_high | medium ≠ | 0.82 | medium medium medium |
| tree | 5.121 | very_high | high ≠ | 0.52 | high medium high |
| distribution | 5.108 | very_high | medium ≠ | 0.74 | medium medium medium |
| dream | 5.056 | very_high | medium ≠ | 0.58 | medium medium medium |
| truth | 5.047 | very_high | high ≠ | 0.53 | high high high |
| delivery | 5.035 | very_high | high ≠ | 0.64 | high high high |
| immediately | 5.023 | very_high | high ≠ | 0.64 | high high high |
| serious | 5.013 | very_high | high ≠ | 0.76 | high high high |
| analyze | 5.005 | very_high | medium ≠ | 0.82 | medium medium medium |
| employee | 4.973 | high | medium ≠ | 0.68 | medium medium medium |
| mass | 4.969 | high | medium ≠ | 0.71 | medium medium medium |
| federal | 4.918 | high | medium ≠ | 0.84 | medium medium medium |
| declare | 4.870 | high | medium ≠ | 0.82 | medium medium medium |
| instance | 4.852 | high | medium ≠ | 0.68 | medium medium medium |
| meaning | 4.674 | high | high | 0.61 | high high high |
| inclusion | 4.670 | high | medium ≠ | 0.67 | medium medium medium |
| sum | 4.587 | high | medium ≠ | 0.47 | medium medium medium |
| quantify | 4.569 | high | limited ≠ | 0.82 | limited limited limited |
| tag | 4.559 | high | medium ≠ | 0.66 | medium medium medium |
| campus | 4.537 | high | medium ≠ | 0.67 | medium medium medium |
| fatigue | 4.530 | high | medium ≠ | 0.78 | medium medium medium |
| interior | 4.519 | high | medium ≠ | 0.78 | medium medium medium |
| bread | 4.469 | high | high | 0.59 | high high high |
| grace | 4.458 | high | medium ≠ | 0.76 | medium medium medium |
| template | 4.440 | high | medium ≠ | 0.64 | medium medium medium |
| weakness | 4.420 | high | medium ≠ | 0.72 | medium medium medium |
| brilliant | 4.408 | high | medium ≠ | 0.79 | medium medium medium |
| encompass | 4.385 | high | limited ≠ | 0.84 | limited limited limited |
| specimen | 4.376 | high | limited ≠ | 0.91 | limited limited limited |
| absent | 4.358 | high | high | 0.53 | high medium medium |
| overview | 4.355 | high | medium ≠ | 0.86 | medium medium medium |
| cabinet | 4.336 | high | medium ≠ | 0.79 | medium medium medium |
| firmly | 4.288 | high | medium ≠ | 0.82 | medium medium medium |
| melt | 4.277 | high | medium ≠ | 0.58 | medium high medium |
| determined | 4.259 | high | medium ≠ | 0.78 | medium medium medium |
| binary | 4.244 | high | limited ≠ | 0.78 | limited limited limited |
| refund | 4.233 | high | medium ≠ | 0.75 | medium medium medium |
| corruption | 4.228 | high | medium ≠ | 0.90 | medium medium medium |
| bypass | 4.117 | high | medium ≠ | 0.82 | medium medium medium |
| mutter | 4.116 | high | medium ≠ | 0.72 | medium medium medium |
| aspiration | 4.111 | high | limited ≠ | 0.77 | limited limited limited |
| depletion | 4.092 | high | limited ≠ | 0.61 | limited limited limited |
| discontinue | 4.076 | high | medium ≠ | 0.77 | medium medium medium |
| stance | 4.057 | high | medium ≠ | 0.86 | medium medium medium |
| unforgettable | 4.042 | high | medium ≠ | 0.70 | medium medium medium |
| iteration | 4.040 | high | limited ≠ | 0.91 | limited limited limited |
| revelation | 4.039 | high | limited ≠ | 0.65 | limited limited limited |
| fortunate | 4.025 | high | medium ≠ | 0.81 | medium medium medium |
| bomber | 4.010 | high | medium ≠ | 0.71 | medium medium medium |
| disappearance | 3.938 | medium | medium | 0.80 | medium medium medium |
| ignorant | 3.933 | medium | medium | 0.82 | medium medium medium |
| terribly | 3.922 | medium | medium | 0.59 | medium medium medium |
| optic | 3.915 | medium | limited ≠ | 0.81 | limited limited limited |
| coup | 3.901 | medium | medium | 0.66 | medium medium medium |
| enlarge | 3.882 | medium | medium | 0.70 | medium medium medium |
| torment | 3.828 | medium | limited ≠ | 0.68 | limited limited limited |
| whore | 3.784 | medium | limited ≠ | 0.76 | limited limited limited |
| lumbar | 3.646 | medium | limited ≠ | 0.88 | limited limited limited |
| watershed | 3.643 | medium | limited ≠ | 0.79 | limited limited limited |
| magnification | 3.602 | medium | limited ≠ | 0.89 | limited limited limited |
| used | 3.596 | medium | high ≠ | 0.60 | high high high |
| irrespective | 3.578 | medium | limited ≠ | 0.74 | limited limited limited |
| injectable | 3.576 | medium | limited ≠ | 0.89 | limited limited limited |
| cardboard | 3.546 | medium | medium | 0.67 | medium medium medium |
| muffin | 3.492 | medium | limited ≠ | 0.52 | limited limited limited |
| functionalize | 3.489 | medium | limited ≠ | 0.64 | limited limited limited |
| schooling | 3.481 | medium | medium | 0.60 | medium medium medium |
| anthropometric | 3.401 | medium | limited ≠ | 0.73 | limited limited limited |
| inbreed | 3.395 | medium | limited ≠ | 0.88 | limited limited limited |
| lifeless | 3.363 | medium | limited ≠ | 0.61 | limited limited limited |
| mite | 3.347 | medium | limited ≠ | 0.69 | limited limited limited |
| compatriot | 3.336 | medium | limited ≠ | 0.93 | limited limited limited |
| postural | 3.285 | medium | limited ≠ | 0.90 | limited limited limited |
| drafting | 3.281 | medium | limited ≠ | 0.82 | limited limited limited |
| pterygium | 3.277 | medium | low ≠ | 0.79 | low low low |
| cynicism | 3.251 | medium | medium | 0.71 | medium medium medium |
| appreciative | 3.246 | medium | medium | 0.69 | medium medium medium |
| capsid | 3.223 | medium | low ≠ | 0.68 | low low low |
| stopping | 3.215 | medium | high ≠ | 0.56 | high high high |
| drake | 3.194 | medium | limited ≠ | 0.72 | limited limited limited |
| cuckoo | 3.192 | medium | limited ≠ | 0.53 | limited limited limited |
| cornea | 3.178 | medium | limited ≠ | 0.82 | limited limited limited |
| spearman | 3.175 | medium | limited ≠ | 0.75 | limited limited limited |
| alkali | 3.168 | medium | limited ≠ | 0.90 | limited limited limited |
| encase | 3.133 | medium | limited ≠ | 0.93 | limited limited limited |
| wallaby | 3.107 | medium | low ≠ | 0.66 | low low low |
| hemicellulose | 3.075 | medium | low ≠ | 0.72 | low low low |
| stupor | 3.069 | medium | limited ≠ | 0.92 | limited limited limited |
| turnkey | 3.037 | medium | limited ≠ | 0.81 | limited limited limited |
| layman | 2.960 | limited | medium ≠ | 0.58 | medium limited limited |
| pelican | 2.935 | limited | limited | 0.75 | limited limited limited |
| urinate | 2.893 | limited | limited | 0.72 | limited limited limited |
| doable | 2.873 | limited | medium ≠ | 0.74 | medium medium medium |
| sooth | 2.829 | limited | limited | 0.54 | limited limited limited |
| peaking | 2.827 | limited | medium ≠ | 0.76 | medium medium medium |
| saponin | 2.820 | limited | low ≠ | 0.72 | low low low |
| tocopherol | 2.813 | limited | low ≠ | 0.60 | low low low |
| uncertainly | 2.774 | limited | medium ≠ | 0.58 | medium medium limited |
| unambiguously | 2.772 | limited | limited | 0.84 | limited limited limited |
| kipper | 2.734 | limited | limited | 0.72 | limited limited limited |
| recitative | 2.682 | limited | low ≠ | 0.62 | low low low |
| stalking | 2.667 | limited | medium ≠ | 0.68 | medium medium medium |
| deprave | 2.629 | limited | limited | 0.93 | limited limited limited |
| hyperexcitability | 2.571 | limited | limited | 0.86 | limited limited limited |
| cohabitation | 2.548 | limited | limited | 0.72 | limited limited limited |
| quinoline | 2.517 | limited | low ≠ | 0.85 | low low low |
| blackmailer | 2.500 | limited | limited | 0.70 | limited limited limited |
| goiter | 2.419 | limited | limited | 0.81 | limited limited limited |
| mudflow | 2.414 | limited | limited | 0.89 | limited limited limited |
| obliged | 2.378 | limited | medium ≠ | 0.57 | medium medium limited |
| disparaging | 2.341 | limited | medium ≠ | 0.60 | medium medium limited |
| mesmeric | 2.330 | limited | limited | 0.92 | limited limited limited |
| lettered | 2.330 | limited | limited | 0.70 | limited limited limited |
| heptane | 2.317 | limited | low ≠ | 0.80 | low low low |
| hyperopic | 2.294 | limited | limited | 0.65 | limited limited limited |
| electrostatically | 2.292 | limited | limited | 0.68 | limited limited limited |
| mani | 2.272 | limited | low ≠ | 0.12 | low low low |
| roading | 2.240 | limited | limited | 0.82 | limited limited limited |
| hake | 2.233 | limited | limited | 0.68 | limited limited limited |
| typhus | 2.232 | limited | limited | 0.81 | limited limited limited |
| blad | 2.200 | limited | low ≠ | 0.03 | low low low |
| ambit | 2.161 | limited | limited | 0.85 | limited limited limited |
| conjugated | 2.148 | limited | limited | 0.82 | limited limited limited |
| dazed | 2.104 | limited | medium ≠ | 0.72 | medium medium medium |
| indiscipline | 2.101 | limited | limited | 0.69 | limited limited limited |
| outstay | 2.053 | limited | limited | 0.86 | limited limited limited |
| stilly | 2.051 | limited | limited | 0.72 | limited limited limited |
| madonna | 2.023 | limited | limited | 0.71 | limited limited limited |
| protestingly | 2.022 | limited | limited | 0.91 | limited limited limited |
| yammer | 1.997 | low | limited ≠ | 0.80 | limited limited limited |
| bridged | 1.978 | low | medium ≠ | 0.63 | medium medium medium |
| nosh | 1.915 | low | limited ≠ | 0.72 | limited limited limited |
| loblolly | 1.888 | low | low | 0.69 | low low low |
| expansiveness | 1.785 | low | limited ≠ | 0.93 | limited limited limited |
| momo | 1.782 | low | low | 0.62 | low low low |
| stam | 1.760 | low | low | 0.17 | low low low |
| toroid | 1.720 | low | low | 0.80 | low low low |
| cheviot | 1.703 | low | low | 0.67 | low low low |
| tapa | 1.675 | low | limited ≠ | 0.62 | limited limited limited |
| sourwood | 1.618 | low | low | 0.77 | low low low |
| undernourishment | 1.611 | low | limited ≠ | 0.88 | limited limited limited |
| yis | 1.545 | low | low | 0.42 | low low low |
| uninterestedly | 1.545 | low | limited ≠ | 0.88 | limited limited limited |
| dispossessory | 1.519 | low | low | 0.73 | low low low |
| mentary | 1.490 | low | limited ≠ | 0.37 | limited limited limited |
| ethel | 1.472 | low | low | 0.80 | low low low |
| conchologist | 1.460 | low | low | 0.87 | low low low |
| zapotec | 1.457 | low | low | 0.65 | low low low |
| locomote | 1.392 | low | low | 0.58 | low low limited |
| comparer | 1.343 | low | limited ≠ | 0.70 | limited limited limited |
| whitener | 1.330 | low | limited ≠ | 0.72 | limited limited limited |
| cag | 1.276 | low | low | 0.64 | low low low |
| standardizable | 1.276 | low | limited ≠ | 0.63 | limited limited limited |
| capriole | 1.244 | low | low | 0.73 | low low low |
| whimperingly | 1.244 | low | limited ≠ | 0.81 | limited limited limited |
| maxixe | 1.244 | low | low | 0.87 | low low low |
| sentimentalize | 1.244 | low | limited ≠ | 0.94 | limited limited limited |
| ladies | 1.187 | low | medium ≠ | 0.53 | medium medium medium |
| exequatur | 1.159 | low | low | 0.80 | low low low |
| hydrid | 1.159 | low | low | 0.63 | low low low |
| chamfron | 1.159 | low | low | 0.90 | low low low |
| phanariote | 1.159 | low | low | 0.82 | low low low |
| gavial | 1.159 | low | low | 0.71 | low low low |
| outstart | 1.159 | low | low | 0.69 | low low low |
| mylonite | 1.159 | low | low | 0.96 | low low low |
| reget | 0.917 | low | low | 0.16 | low low low |
| stockbridge | 0.917 | low | low | 0.74 | low low low |
| stunter | 0.917 | low | limited ≠ | 0.67 | limited limited limited |
| proofer | 0.853 | low | limited ≠ | 0.78 | limited limited limited |

## programming (200 слов)

- Точное совпадение уровня: **26%** (критерий: окно 80% … 90%)
- Совпадение с точностью до одного уровня: 82%
- Расхождений для слепой оценки: 147 (критерий: не менее 20)
- Стабильность повторов: **95%** (критерий: не менее 95%)
- Средний сдвиг JEV относительно частоты: -0.55 уровня

| слово | Zipf | Zipf core | специфичность | частота | JEV | conf | повторы |
|---|---|---|---|---|---|---|---|
| object | 6.507 | 4.913 | very_high | very_high | very_high | 0.70 | very_high very_high very_high |
| return | 6.387 | 5.615 | medium | very_high | very_high | 0.51 | very_high very_high very_high |
| get | 6.326 | 6.370 | baseline | very_high | very_high | 0.54 | very_high very_high very_high |
| method | 6.317 | 5.407 | medium | very_high | high ≠ | 0.45 | high very_high very_high |
| way | 6.174 | 5.937 | baseline | very_high | high ≠ | 0.39 | high high high |
| instance | 5.972 | 4.852 | high | very_high | high ≠ | 0.76 | high high high |
| model | 5.958 | 5.771 | baseline | very_high | high ≠ | 0.61 | high high high |
| problem | 5.857 | 5.396 | low | very_high | very_high | 0.61 | very_high very_high very_high |
| form | 5.798 | 5.608 | baseline | very_high | high ≠ | 0.52 | high high high |
| post | 5.773 | 5.477 | baseline | very_high | medium ≠ | 0.53 | medium medium medium |
| detail | 5.755 | 5.257 | low | very_high | high ≠ | 0.52 | high high high |
| correct | 5.746 | 4.821 | medium | very_high | high ≠ | 0.46 | high high high |
| good | 5.736 | 6.131 | baseline | very_high | very_high | 0.38 | very_high very_high very_high |
| section | 5.736 | 5.175 | low | very_high | medium ≠ | 0.33 | medium medium medium |
| loop | 5.729 | 4.558 | high | very_high | very_high | 0.57 | very_high very_high very_high |
| column | 5.707 | 4.609 | high | very_high | medium ≠ | 0.67 | medium medium medium |
| empty | 5.550 | 4.697 | medium | very_high | high ≠ | 0.63 | high high high |
| modify | 5.540 | 4.711 | medium | very_high | high ≠ | 0.64 | high high high |
| header | 5.537 | 3.880 | very_high | very_high | high ≠ | 0.69 | high high high |
| tell | 5.535 | 5.966 | baseline | very_high | medium ≠ | 0.28 | medium medium high |
| slice | 5.534 | 4.292 | high | very_high | high ≠ | 0.43 | high high medium |
| particular | 5.475 | 5.032 | low | very_high | medium ≠ | 0.68 | medium medium medium |
| difference | 5.471 | 5.432 | baseline | very_high | medium ≠ | 0.56 | medium medium medium |
| usage | 5.363 | 4.527 | medium | very_high | medium ≠ | 0.57 | medium medium medium |
| publish | 5.305 | 5.290 | baseline | very_high | limited ≠ | 0.58 | limited limited limited |
| least | 5.284 | 5.369 | baseline | very_high | medium ≠ | 0.52 | medium medium medium |
| unit | 5.272 | 5.186 | baseline | very_high | medium ≠ | 0.46 | medium medium medium |
| purpose | 5.256 | 5.115 | baseline | very_high | medium ≠ | 0.62 | medium medium medium |
| unique | 5.248 | 5.059 | baseline | very_high | medium ≠ | 0.56 | medium medium high |
| self | 5.193 | 5.365 | baseline | very_high | high ≠ | 0.52 | high high high |
| driver | 5.121 | 5.046 | baseline | very_high | medium ≠ | 0.57 | medium medium medium |
| alternative | 5.090 | 4.927 | baseline | very_high | medium ≠ | 0.67 | medium medium medium |
| unsafe | 5.090 | 3.795 | high | very_high | medium ≠ | 0.53 | medium medium medium |
| pair | 5.073 | 5.032 | baseline | very_high | medium ≠ | 0.55 | medium medium medium |
| device | 5.067 | 5.118 | baseline | very_high | medium ≠ | 0.60 | medium medium medium |
| float | 5.061 | 4.474 | low | very_high | high ≠ | 0.34 | high medium high |
| verbose | 5.047 | 2.357 | very_high | very_high | limited ≠ | 0.72 | limited limited limited |
| active | 5.041 | 5.115 | baseline | very_high | high ≠ | 0.66 | high high high |
| comma | 5.007 | 2.917 | very_high | very_high | very_high | 0.11 | very_high very_high very_high |
| aware | 5.006 | 4.733 | baseline | very_high | medium ≠ | 0.61 | medium medium medium |
| focus | 4.945 | 5.510 | baseline | high | medium ≠ | 0.58 | medium medium medium |
| internally | 4.918 | 3.876 | medium | high | medium ≠ | 0.66 | medium medium medium |
| week | 4.833 | 5.612 | baseline | high | medium ≠ | 0.54 | medium medium medium |
| protect | 4.804 | 5.242 | baseline | high | medium ≠ | 0.64 | medium medium medium |
| concrete | 4.772 | 4.451 | baseline | high | medium ≠ | 0.43 | medium medium medium |
| incompatible | 4.742 | 3.397 | high | high | high | 0.66 | high high high |
| eliminate | 4.716 | 4.729 | baseline | high | medium ≠ | 0.67 | medium medium medium |
| grow | 4.683 | 5.525 | baseline | high | limited ≠ | 0.53 | limited limited limited |
| understanding | 4.616 | 4.969 | baseline | high | medium ≠ | 0.44 | medium medium medium |
| refresh | 4.610 | 4.124 | low | high | high | 0.61 | high high high |
| kill | 4.604 | 5.486 | baseline | high | medium ≠ | 0.52 | medium medium medium |
| interesting | 4.599 | 4.766 | baseline | high | medium ≠ | 0.51 | medium medium medium |
| acquire | 4.579 | 4.902 | baseline | high | limited ≠ | 0.47 | limited limited limited |
| retain | 4.525 | 4.805 | baseline | high | medium ≠ | 0.63 | medium medium medium |
| destination | 4.502 | 4.609 | baseline | high | limited ≠ | 0.56 | limited limited limited |
| writable | 4.449 | 2.078 | very_high | high | medium ≠ | 0.54 | medium medium limited |
| overlay | 4.448 | 3.805 | low | high | medium ≠ | 0.72 | medium medium medium |
| margin | 4.442 | 4.558 | baseline | high | medium ≠ | 0.59 | medium medium medium |
| preferred | 4.439 | 4.249 | baseline | high | medium ≠ | 0.70 | medium medium medium |
| corrupt | 4.432 | 3.885 | low | high | medium ≠ | 0.54 | medium medium medium |
| interest | 4.424 | 5.324 | baseline | high | medium ≠ | 0.48 | medium medium medium |
| delegate | 4.417 | 4.111 | baseline | high | medium ≠ | 0.52 | medium medium medium |
| vendor | 4.402 | 4.385 | baseline | high | limited ≠ | 0.74 | limited limited limited |
| odd | 4.327 | 4.751 | baseline | high | medium ≠ | 0.55 | medium medium medium |
| problematic | 4.297 | 3.903 | low | high | medium ≠ | 0.75 | medium medium medium |
| intuitive | 4.215 | 4.004 | baseline | high | medium ≠ | 0.72 | medium medium medium |
| card | 4.206 | 5.061 | baseline | high | limited ≠ | 0.60 | limited limited limited |
| picture | 4.205 | 5.065 | baseline | high | medium ≠ | 0.62 | medium medium medium |
| browse | 4.195 | 4.195 | baseline | high | medium ≠ | 0.57 | medium medium medium |
| billing | 4.175 | 3.933 | baseline | high | limited ≠ | 0.66 | limited limited limited |
| specifier | 4.165 | 1.958 | very_high | high | medium ≠ | 0.55 | medium medium medium |
| descendant | 4.158 | 4.054 | baseline | high | limited ≠ | 0.55 | limited limited limited |
| confused | 4.043 | 4.048 | baseline | high | medium ≠ | 0.58 | medium medium medium |
| truth | 4.029 | 5.047 | baseline | high | limited ≠ | 0.32 | limited limited limited |
| student | 4.025 | 5.514 | baseline | high | limited ≠ | 0.63 | limited limited limited |
| dumb | 4.025 | 4.141 | baseline | high | limited ≠ | 0.48 | limited limited limited |
| ugly | 4.020 | 4.230 | baseline | high | limited ≠ | 0.63 | limited limited limited |
| noticeable | 4.012 | 3.915 | baseline | high | limited ≠ | 0.68 | limited limited limited |
| analytic | 4.008 | 4.514 | baseline | high | medium ≠ | 0.68 | medium medium medium |
| uniform | 4.007 | 4.529 | baseline | high | limited ≠ | 0.69 | limited limited limited |
| folk | 3.973 | 4.711 | baseline | medium | limited ≠ | 0.61 | limited limited limited |
| nonexistent | 3.914 | 2.932 | medium | medium | limited ≠ | 0.56 | limited limited limited |
| ascend | 3.904 | 4.018 | baseline | medium | limited ≠ | 0.72 | limited limited limited |
| aggressive | 3.898 | 4.427 | baseline | medium | limited ≠ | 0.63 | limited limited limited |
| quota | 3.803 | 3.615 | baseline | medium | medium | 0.66 | medium medium medium |
| chinese | 3.751 | 4.864 | baseline | medium | limited ≠ | 0.62 | limited limited limited |
| rounded | 3.750 | 3.855 | baseline | medium | limited ≠ | 0.50 | limited limited limited |
| modernize | 3.692 | 3.740 | baseline | medium | limited ≠ | 0.57 | limited medium medium |
| swift | 3.606 | 4.184 | baseline | medium | medium | 0.42 | medium medium medium |
| busy | 3.604 | 4.737 | baseline | medium | medium | 0.48 | medium medium medium |
| unpublished | 3.568 | 3.426 | baseline | medium | limited ≠ | 0.70 | limited limited limited |
| storm | 3.565 | 4.762 | baseline | medium | limited ≠ | 0.67 | limited limited limited |
| fish | 3.518 | 4.864 | baseline | medium | limited ≠ | 0.51 | limited limited limited |
| convoluted | 3.484 | 2.790 | low | medium | limited ≠ | 0.67 | limited limited limited |
| drift | 3.477 | 4.350 | baseline | medium | medium | 0.56 | medium medium medium |
| preimage | 3.465 | — | very_high | medium | limited ≠ | 0.76 | limited limited limited |
| roster | 3.422 | 4.408 | baseline | medium | limited ≠ | 0.70 | limited limited limited |
| nuance | 3.410 | 3.839 | baseline | medium | limited ≠ | 0.80 | limited limited limited |
| wary | 3.401 | 3.560 | baseline | medium | limited ≠ | 0.81 | limited limited limited |
| fip | 3.363 | 2.072 | medium | medium | low ≠ | 0.59 | low low low |
| predictor | 3.355 | 4.427 | baseline | medium | medium | 0.61 | medium medium medium |
| russian | 3.337 | 4.882 | baseline | medium | limited ≠ | 0.62 | limited limited limited |
| revalidate | 3.335 | 1.593 | high | medium | limited ≠ | 0.72 | limited limited limited |
| subgroup | 3.304 | 4.479 | baseline | medium | limited ≠ | 0.55 | limited limited limited |
| continually | 3.292 | 3.982 | baseline | medium | limited ≠ | 0.64 | limited limited limited |
| definitively | 3.266 | 3.475 | baseline | medium | limited ≠ | 0.68 | limited limited limited |
| wholly | 3.264 | 4.046 | baseline | medium | limited ≠ | 0.82 | limited limited limited |
| cosmic | 3.235 | 3.690 | baseline | medium | limited ≠ | 0.59 | limited limited limited |
| reliance | 3.214 | 4.229 | baseline | medium | limited ≠ | 0.70 | limited limited limited |
| speculate | 3.208 | 3.969 | baseline | medium | limited ≠ | 0.82 | limited limited limited |
| searchable | 3.206 | 3.145 | baseline | medium | medium | 0.68 | medium medium medium |
| branchless | 3.179 | — | high | medium | limited ≠ | 0.64 | limited limited limited |
| fearless | 3.166 | 3.558 | baseline | medium | low ≠ | 0.58 | low low low |
| unresolve | 3.161 | 1.663 | medium | medium | limited ≠ | 0.49 | limited limited limited |
| arbiter | 3.141 | 2.807 | baseline | medium | limited ≠ | 0.68 | limited limited limited |
| warp | 3.115 | 3.624 | baseline | medium | limited ≠ | 0.70 | limited limited limited |
| cup | 3.066 | 4.640 | baseline | medium | limited ≠ | 0.60 | limited limited limited |
| junction | 3.050 | 4.187 | baseline | medium | limited ≠ | 0.51 | limited limited limited |
| entitle | 3.046 | 4.373 | baseline | medium | limited ≠ | 0.58 | limited limited limited |
| intermix | 3.003 | 2.738 | baseline | medium | limited ≠ | 0.76 | limited limited limited |
| fluid | 2.984 | 4.586 | baseline | limited | limited | 0.57 | limited limited limited |
| housekeeping | 2.955 | 3.520 | baseline | limited | limited | 0.62 | limited limited limited |
| monotonically | 2.924 | 2.623 | baseline | limited | limited | 0.59 | limited limited limited |
| syntactical | 2.901 | — | medium | limited | limited | 0.52 | limited limited limited |
| boon | 2.878 | 3.304 | baseline | limited | limited | 0.69 | limited limited limited |
| fashioned | 2.878 | 3.926 | baseline | limited | limited | 0.74 | limited limited limited |
| jumble | 2.865 | 2.845 | baseline | limited | limited | 0.74 | limited limited limited |
| pervasiveness | 2.865 | 2.057 | low | limited | limited | 0.81 | limited limited limited |
| wet | 2.847 | 4.485 | baseline | limited | limited | 0.50 | limited limited limited |
| materially | 2.814 | 3.981 | baseline | limited | limited | 0.75 | limited limited limited |
| clothe | 2.814 | 4.751 | baseline | limited | low ≠ | 0.52 | low low low |
| loophole | 2.814 | 3.417 | baseline | limited | limited | 0.79 | limited limited limited |
| pot | 2.799 | 4.327 | baseline | limited | limited | 0.57 | limited limited limited |
| constituent | 2.769 | 3.941 | baseline | limited | limited | 0.59 | limited limited limited |
| unbind | 2.769 | 2.051 | low | limited | limited | 0.64 | limited limited limited |
| recode | 2.769 | 2.768 | baseline | limited | medium ≠ | 0.72 | medium medium medium |
| dependence | 2.720 | 4.257 | baseline | limited | medium ≠ | 0.52 | medium medium medium |
| pity | 2.683 | 4.401 | baseline | limited | limited | 0.62 | limited limited limited |
| lasting | 2.634 | 3.946 | baseline | limited | limited | 0.66 | limited limited limited |
| reaper | 2.623 | 2.777 | baseline | limited | limited | 0.62 | limited low limited |
| tri | 2.623 | 3.426 | baseline | limited | limited | 0.45 | limited limited limited |
| expendable | 2.623 | 2.841 | baseline | limited | limited | 0.74 | limited limited limited |
| disassociate | 2.623 | 2.430 | baseline | limited | limited | 0.76 | limited limited limited |
| salvage | 2.623 | 3.735 | baseline | limited | limited | 0.78 | limited limited limited |
| keel | 2.577 | 3.402 | baseline | limited | low ≠ | 0.52 | low low low |
| comb | 2.577 | 3.768 | baseline | limited | limited | 0.62 | limited limited limited |
| reification | 2.577 | 2.277 | baseline | limited | limited | 0.77 | limited limited limited |
| deformation | 2.577 | 3.825 | baseline | limited | limited | 0.63 | limited limited limited |
| shabby | 2.577 | 3.539 | baseline | limited | limited | 0.66 | limited limited limited |
| annihilation | 2.577 | 3.156 | baseline | limited | low ≠ | 0.59 | low low limited |
| television | 2.577 | 4.877 | baseline | limited | limited | 0.56 | limited limited limited |
| contiguously | 2.577 | 0.917 | low | limited | limited | 0.82 | limited limited limited |
| demon | 2.577 | 4.069 | baseline | limited | limited | 0.60 | limited limited limited |
| pyx | 2.577 | 1.695 | low | limited | low ≠ | 0.71 | low low low |
| unhand | 2.577 | 2.408 | baseline | limited | low ≠ | 0.66 | low low low |
| errant | 2.513 | 2.744 | baseline | limited | limited | 0.57 | limited limited limited |
| doghouse | 2.513 | 2.362 | baseline | limited | low ≠ | 0.68 | low low low |
| unveil | 2.513 | 4.212 | baseline | limited | limited | 0.70 | limited limited limited |
| pray | 2.513 | 4.584 | baseline | limited | limited | 0.56 | limited limited limited |
| passively | 2.513 | 3.179 | baseline | limited | limited | 0.74 | limited limited limited |
| demarcate | 2.498 | 2.826 | baseline | low | limited ≠ | 0.73 | limited limited limited |
| hypotenuse | 2.498 | 1.947 | baseline | low | limited ≠ | 0.78 | limited limited limited |
| logman | 2.498 | — | low | low | low | 0.77 | low low low |
| territorial | 2.498 | 3.885 | baseline | low | limited ≠ | 0.68 | limited limited limited |
| synch | 2.498 | 2.062 | baseline | low | limited ≠ | 0.36 | limited limited limited |
| insect | 2.322 | 4.265 | baseline | low | limited ≠ | 0.40 | limited limited limited |
| imprecision | 2.322 | 3.024 | baseline | low | limited ≠ | 0.71 | limited limited limited |
| prize | 2.322 | 4.517 | baseline | low | limited ≠ | 0.70 | limited limited limited |
| banking | 2.322 | 4.284 | baseline | low | limited ≠ | 0.52 | limited limited limited |
| overfly | 2.322 | 1.825 | baseline | low | low | 0.76 | low low low |
| urgency | 2.322 | 3.862 | baseline | low | limited ≠ | 0.72 | limited limited limited |
| dragonfly | 2.322 | 2.873 | baseline | low | low | 0.74 | low low low |
| reconstructor | 2.322 | — | low | low | limited ≠ | 0.77 | limited limited limited |
| tentatively | 2.322 | 3.220 | baseline | low | limited ≠ | 0.81 | limited limited limited |
| pasting | 2.021 | 1.877 | baseline | low | medium ≠ | 0.38 | medium medium medium |
| compressibility | 2.021 | 2.540 | baseline | low | limited ≠ | 0.67 | limited limited limited |
| cycling | 2.021 | 4.087 | baseline | low | limited ≠ | 0.50 | limited limited limited |
| shish | 2.021 | 1.898 | baseline | low | low | 0.82 | low low low |
| unrecognizable | 2.021 | 2.762 | baseline | low | limited ≠ | 0.78 | limited limited limited |
| differentiator | 2.021 | 3.171 | baseline | low | limited ≠ | 0.70 | limited limited limited |
| pictographic | 2.021 | 1.569 | baseline | low | limited ≠ | 0.68 | limited limited limited |
| tidily | 2.021 | 1.785 | baseline | low | limited ≠ | 0.75 | limited limited limited |
| uncomfortably | 2.021 | 3.042 | baseline | low | limited ≠ | 0.77 | limited limited limited |
| experimenter | 2.021 | 3.103 | baseline | low | limited ≠ | 0.82 | limited limited limited |
| nonportable | 2.021 | — | baseline | low | limited ≠ | 0.72 | limited limited limited |
| depender | 2.021 | 1.439 | baseline | low | medium ≠ | 0.19 | medium medium low |
| confusable | 2.021 | — | baseline | low | limited ≠ | 0.76 | limited limited limited |
| bitemporal | 2.021 | 1.753 | baseline | low | limited ≠ | 0.70 | limited limited limited |
| tidiness | 2.021 | 2.156 | baseline | low | limited ≠ | 0.72 | limited limited limited |
| threefold | 2.021 | 2.970 | baseline | low | limited ≠ | 0.73 | limited limited limited |
| obviate | 2.021 | 2.684 | baseline | low | limited ≠ | 0.79 | limited limited limited |
| laborious | 2.021 | 3.108 | baseline | low | limited ≠ | 0.84 | limited limited limited |
| rigidity | 2.021 | 3.575 | baseline | low | limited ≠ | 0.72 | limited limited limited |
| reinitiate | 2.021 | 2.267 | baseline | low | limited ≠ | 0.62 | limited limited limited |
| nonobvious | 2.021 | 1.276 | baseline | low | limited ≠ | 0.77 | limited limited limited |
| ramification | 2.021 | 3.179 | baseline | low | limited ≠ | 0.82 | limited limited limited |
| tutor | 2.021 | 4.004 | baseline | low | limited ≠ | 0.58 | limited limited limited |
| tale | 2.021 | 4.475 | baseline | low | low | 0.62 | low low low |
| distorted | 2.021 | 3.298 | baseline | low | limited ≠ | 0.82 | limited limited limited |
| princess | 2.021 | 4.124 | baseline | low | low | 0.81 | low low low |

Задержка: медиана 1023 мс, p95 1154 мс (1200 вызовов)
