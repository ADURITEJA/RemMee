🧠 Dementia Memory App

A smart AI-powered app designed to assist dementia patients in memory recall and cognitive engagement.

📌 Overview

Dementia affects millions worldwide, making memory loss and daily routines challenging. Our app enhances memory recall and engagement through AI-powered features, personalized reminders, and interactive games, helping both patients and caregivers.

🚀 Features

👁️ Memory Recall & AI Word Game
	•	Patients can record memories via speech or text, which the app analyzes using BERT NLP.
	•	AI generates interactive word games based on past memories to stimulate cognitive recall.
	•	Real-time feedback and hints encourage active participation.

📊 Memory Analysis & 3D Pie Chart
	•	Extracted keywords from memory texts are analyzed using BERT & Google ML Kit.
	•	Memories are categorized as Strongly Remembered, Moderately Remembered, Weakly Remembered, or Forgotten.
	•	A 3D Pie Chart provides a visual representation of memory retention trends.

⏰ Personalized Schedules & Reminders
	•	Users can set and manage schedules, ensuring daily routines are followed.
	•	Priority alerts notify patients about important tasks and events.
	•	Caregivers can remotely assign tasks, improving care coordination.

🔔 Smart Notifications
	•	Uses Flutter Local Notifications to remind patients about daily activities.
	•	Custom time-based and priority-based alerts enhance routine management.

🛡️ Data Security & Privacy
	•	All user data is stored locally in SQLite, ensuring no external data breaches.
	•	AES encryption secures stored memory texts to maintain privacy.
	•	No cloud dependency avoids security vulnerabilities.

⸻

🛠️ Tech Stack

📱 Frontend:
	•	Flutter (Dart) – Cross-platform UI framework for a smooth and intuitive experience.

🧠 AI & NLP:
	•	BERT (Bidirectional Encoder Representations from Transformers) – Used for keyword extraction and NLP analysis of patient memories.
	•	Google ML Kit – Entity extraction for memory categorization and cognitive analysis.

💾 Database:
	•	SQLite – Stores patient memories, schedules, and caregiver tasks locally.
	•	Shared Preferences – Stores user settings and preferences securely.

🔔 Notifications & Alerts:
	•	Flutter Local Notifications – Used for reminders and alerts with custom time-based scheduling.

📊 Data Visualization:
	•	Syncfusion Flutter Charts – Generates interactive 3D pie charts for memory analysis reports.
