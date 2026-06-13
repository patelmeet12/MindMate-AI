# MindMate AI — Student Mental Wellness Companion

MindMate AI is a production-ready, clinical-wellness-inspired web application designed for students preparing for high-stakes examinations (JEE, NEET, UPSC, CAT, GATE, CUET). The platform focuses on identifying hidden stress triggers, tracking physical study-life balance indices, and providing offline, empathetic wellness recommendations.

It is built with **Flutter Web**, using **Riverpod** for state coordination, **GoRouter** for responsive shell navigation, and **SharedPreferences** for secure local storage.

---

## 1. Problem Statement
Aspirants preparing for competitive exams face severe emotional pressure, parental expectations, peer competition, and sleep deprivation. Standard journaling apps or generic mood trackers fail to connect physical habits (sleep and study hours) with emotional symptoms. Students need a supportive companion that:
- Captures emotional changes and logs daily moods.
- Analyzes written reflections to identify academic stress.
- Flags recurring triggers (e.g. mock test anxiety, peer comparison) over time.
- Operates entirely offline to ensure complete privacy.

---

## 2. Solution Overview
MindMate AI establishes a supportive wellness loop:
1. **Onboarding Profile**: Users declare target exams and daily study/sleep baselines.
2. **Daily Activity Check-In**: Captures mood states and ratings (1–10) for energy, sleep quality, and motivation.
3. **Local Heuristic AI Journal**: Extracts emotional markers, anxiety, and concerns from text reflections without using external network APIs.
4. **Stress Trigger Alerts**: Analyzes logs over a 7-day window to notify users of recurring triggers (e.g., parental expectations mentioned in 3 out of 5 entries).
5. **Study-Life Balance Index**: Calculates a live wellness score (0–100) comparing sleep duration and breaks against total study hours.
6. **Adaptive Exercises**: Offers box breathing guides, gratitude logs, and swipable test affirmations.

---

## 3. Heuristic AI Journal Logic
The analysis engine in [AIAnalysisEngine](lib/domain/usecases/ai_analysis_engine.dart) parses written text using keyword density, negation modifiers, and intensity boosters:
- **Concern Detection**: Matches text patterns against vocabulary maps for *Exam Anxiety*, *Peer Comparison*, *Parental Pressure*, *Lack of Sleep*, *Study Overload*, and *Digital Distractions*.
- **Stress Score (0–100)**: Starts with a baseline of 30, adding +12 per concern category detected, adding +10 per intensity modifier (e.g., "extremely", "hopeless"), and subtracting -8 per positive modifier (e.g., "confident", "relaxed").
- **Confidence Score (0–100)**: Starts at 50, adding +12 per positive modifier, and subtracting -8 per concern and -6 per intensity booster.
- **Burnout Risk Evaluation**: Flags **High** risk if the stress score is >= 75 with sleep/study overload concerns, or if both concerns are present with stress >= 60.

---

## 4. Recurring Stress Trigger Detection
The [StressTriggerAnalyzer](lib/domain/usecases/stress_trigger_analyzer.dart) monitors the last 7 entries:
$$\text{Trigger Ratio} = \frac{\text{Entries with Concern Tag}}{\text{Total Recent Entries}}$$
If any concern tag has a ratio $\ge 30\%$ (minimum 2 occurrences), the app displays a highlighted warning on the Journal tab. Actionable, clinically-grounded advice is provided to alter study habits (e.g., implementing Pomodoro study blocks for study overload).

---

## 5. Study-Life Balance Scoring Math
The daily balance score (0–100) is calculated in [StudyLifeStats](lib/domain/models/study_life_stats.dart) as:
- **Base Score**: 100 points.
- **Sleep Deficit**: Deduct 15 points per hour of sleep below 7 hours. Deduct 5 points per hour above 9 hours.
- **Study Overload**: Deduct 12 points per hour of study exceeding 10 hours.
- **Breaks Shortage**: Deduct 15 points if study exceeds 4 hours with 0 breaks. Deduct 8 points if breaks are fewer than 3.
- **Wellness Activities**: Deduct 10 points if no wellness activities are recorded. Add +5 points per logged activity (cap at +10).

---

## 6. Setup & Execution Instructions

### Prerequisites
- Flutter SDK (stable channel, version 3.33+ or 3.38+ recommended)
- Dart SDK
- Chrome browser (for web run)

### Setup
1. Clone the repository and navigate to the project directory:
   ```bash
   cd mindmate_ai
   ```
2. Download packages and dependencies:
   ```bash
   flutter pub get
   ```
3. Run the automated unit tests:
   ```bash
   flutter test
   ```
4. Run the application locally in developer mode:
   ```bash
   flutter run -d chrome
   ```

### Production Build
Build a minimized production bundle for static hosting:
```bash
flutter build web --release
```
The output directory will be created at `build/web/`, which can be served using any static web server (e.g., Nginx, Netlify, or GitHub Pages).

---

## 7. Safety & Clinical Boundaries
MindMate AI is designed as a wellness coaching utility. It **never diagnoses mental illness** or provides clinical prescriptions. The following safety measures are built-in:
- **Disclaimer Banner**: A sticky notice is rendered on the dashboard advising users to consult professionals in severe distress.
- **Companion Safety Intercepts**: If the chat interface detects critical distress keywords (e.g., "kill", "harm", "suicide"), it intercepts immediately, prints national support helpline contact options (Tele-MANAS, etc.), and displays the safety disclaimer.
