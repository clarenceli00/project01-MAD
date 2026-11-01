# AI Feature: Garden Guide

Project: Habit Mastery League  
Pathway: Undergraduate  
Feature type / method label: Explainable local history-based rule (not a trained machine-learning model, generative AI, or health recommendation)  
Implementation: `lib/garden_guide.dart`, `lib/models.dart`; displayed in `lib/screens/history_screen.dart`  
Storage: Existing local SQLite `habits` and `check_ins` tables only; no helper table, network request, or external API.

## 1. Benefit and purpose

Garden Guide suggests a manageable weekly habit target using a habit's recorded activity. Instead of punishing a missed day or enforcing a streak, it offers an optional target based on recent history. The suggestion is explained to the user, who can choose to apply it or keep the current target.

## 2. Inputs, units, and calendar rules

| Input | Source | Unit / meaning |
|---|---|---|
| `Habit.id` | SQLite `habits.id` | Identifier used to select one habit's records |
| `Habit.startedLocalDate` (`startDate` in Dart) | SQLite `habits.started_local_date` | Local calendar date, `YYYY-MM-DD` |
| `Habit.weeklyTarget` | SQLite `habits.weekly_target` | Existing user goal, **days/week**, integer 1–7 |
| `CheckIn.localDate` (`date` in Dart) | SQLite `check_ins.local_date` | Local calendar date, `YYYY-MM-DD` |
| `today` | Injected test date or device local date | Determines current Monday–Sunday calendar week |

A week starts **Monday** and ends **Sunday**. The helper excludes the current (incomplete) week and the habit's partial starting week. It uses the **latest three whole completed eligible weeks**, where a week is eligible only when its Monday is on or after the habit start date. Each week's count is the number of **distinct** saved check-in dates for that habit in that week. Eligible weeks with no check-ins count as **zero days/week**. Dates are stored as date-only strings, not converted into UTC timestamps.

## 3. Method and explanation

For completed eligible weekly counts `c1`, `c2`, and `c3` (each between 0 and 7):

1. Compute the mean: `average = (c1 + c2 + c3) / 3`.
2. Round to the nearest integer, halves up for nonnegative counts.
3. Clamp the result to 1–7 days/week.
4. Show the three week ranges, their distinct day counts, and the calculation.
5. With fewer than three eligible completed weeks, display “Not enough history” and keep the user's target. Invalid input must not produce a suggestion.

Example: Counts 2, 3, 4 days/week yield `(2 + 3 + 4) / 3 = 3`, so Garden Guide suggests 3 days/week. It does not automatically save a new goal.

Why these inputs: Actual recorded completion days, the habit start date, and the current weekly target are already stored locally and are simple to explain. Counting distinct dates prevents accidental double taps or corrections from inflating history.

Alternative considered: The median of the same three weeks reduces sensitivity to an unusually busy or inactive week. We chose the mean because it is simple to explain and uses all three observations. This is a design choice, not proof that the mean is more accurate.

## 4. Baseline and evaluation metric

The baseline predicts the user's unchanged current `weeklyTarget` for the following completed week. The Garden Guide prediction is the rule-based suggestion. Both are compared with the same observed count of distinct check-in days in that following completed week.

- Absolute error (days/week): `|predicted target − following week's actual distinct days|`.
- Mean absolute error (MAE, days/week): sum of absolute errors divided by the number of valid evaluation cases.
- Lower MAE means better agreement with observed later activity in this sample; it does not establish that the recommendation caused habit improvement.
- No accuracy or confidence score is claimed, and invalid or no-data cases are excluded from MAE.


## 5. Implementation references and remaining caution

- `lib/models.dart`: `dateToString()`, `weekStart()`, `weeklyCount()`.
- `lib/garden_guide.dart`: `GardenGuide.suggest()`, `suggestFromCounts()`, `absoluteError()`, `meanAbsoluteError()`.
- `lib/screens/history_screen.dart`: Garden Guide card, Apply and Keep my target actions.
- `lib/screens/habit_editor_screen.dart`: editable target slider and Save/Cancel controls.
- `lib/database_helper.dart`: SQLite record and target persistence.

Implementation verification note: The currently shared code contains the core calculation and UI flow, but this report does not claim the latest UI fixes, offline demonstration, or test suite have been executed. Verify that `GardenGuide.suggest()` filters other habits' check-ins, the card shows the week ranges, and Keep my target actually dismisses the card. Record real output in the final evidence before describing these behaviors as tested.
