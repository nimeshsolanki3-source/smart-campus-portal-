-- ========================================================
-- Smart Campus Event & Workshop Portal
-- Database Schema & Comprehensive Seed Data
-- Compatible with MySQL 5.7+ / 8.0+ / MariaDB / XAMPP
-- ========================================================

CREATE DATABASE IF NOT EXISTS `smart_campus_portal` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `smart_campus_portal`;

-- Disable foreign key checks during creation and data insertion
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables to ensure clean re-runs
DROP TABLE IF EXISTS `contact_messages`;
DROP TABLE IF EXISTS `broadcasts`;
DROP TABLE IF EXISTS `registrations`;
DROP TABLE IF EXISTS `events`;
DROP TABLE IF EXISTS `venues`;
DROP TABLE IF EXISTS `users`;

-- ========================================================
-- 1. USERS TABLE
-- ========================================================
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('student', 'admin', 'organizer') NOT NULL DEFAULT 'student',
  `student_id` VARCHAR(50) NULL,
  `department` VARCHAR(100) NULL,
  `phone` VARCHAR(25) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_users_role` (`role`),
  INDEX `idx_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 2. VENUES TABLE
-- ========================================================
CREATE TABLE `venues` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `venue_name` VARCHAR(120) NOT NULL,
  `building` VARCHAR(100) NOT NULL,
  `capacity` INT NOT NULL,
  `status` ENUM('available', 'maintenance') NOT NULL DEFAULT 'available',
  `location_details` TEXT,
  `amenities` VARCHAR(255) DEFAULT '4K Projector, Surround Audio, High-Speed WiFi, AC',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_venues_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 3. EVENTS TABLE (Includes both Events and Hands-on Workshops)
-- ========================================================
CREATE TABLE `events` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(200) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `event_type` ENUM('event', 'workshop') NOT NULL DEFAULT 'event',
  `short_description` VARCHAR(300) NOT NULL,
  `description` LONGTEXT NOT NULL,
  `venue_id` INT NULL,
  `start_datetime` DATETIME NOT NULL,
  `end_datetime` DATETIME NOT NULL,
  `banner_image` VARCHAR(255) NULL,
  `status` ENUM('draft', 'pending', 'approved', 'closed') NOT NULL DEFAULT 'approved',
  `rules` TEXT NULL,
  `speakers` TEXT NULL,
  `agenda` TEXT NULL,
  `organizer_name` VARCHAR(150) NOT NULL DEFAULT 'Campus Technical Council',
  `max_capacity` INT NOT NULL DEFAULT 100,
  `created_by` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_events_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_events_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX `idx_events_status` (`status`),
  INDEX `idx_events_type` (`event_type`),
  INDEX `idx_events_category` (`category`),
  INDEX `idx_events_start` (`start_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 4. REGISTRATIONS TABLE
-- ========================================================
CREATE TABLE `registrations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `event_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `registration_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `ticket_code` VARCHAR(50) NOT NULL UNIQUE,
  `status` ENUM('registered', 'attended', 'cancelled') NOT NULL DEFAULT 'registered',
  `notes` VARCHAR(255) NULL,
  CONSTRAINT `fk_reg_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reg_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `unique_user_event_reg` (`event_id`, `user_id`),
  INDEX `idx_reg_status` (`status`),
  INDEX `idx_reg_ticket` (`ticket_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 5. BROADCASTS & NOTIFICATIONS TABLE
-- ========================================================
CREATE TABLE `broadcasts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `recipient_group` ENUM('all', 'students', 'organizers') NOT NULL DEFAULT 'all',
  `subject` VARCHAR(200) NOT NULL,
  `message` TEXT NOT NULL,
  `scheduled_at` DATETIME NULL,
  `sent_at` DATETIME NULL,
  `created_by` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_broadcasts_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX `idx_broadcast_group` (`recipient_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- 6. CONTACT & FEEDBACK INQUIRIES
-- ========================================================
CREATE TABLE `contact_messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `subject` VARCHAR(200) NOT NULL,
  `message` TEXT NOT NULL,
  `status` ENUM('unread', 'read', 'resolved') NOT NULL DEFAULT 'unread',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================
-- MOCK SEED DATA
-- Default Passwords:
-- admin@smartcampus.edu   => admin123
-- student@smartcampus.edu => student123
-- john.doe@smartcampus.edu => student123
-- ========================================================

-- Insert Sample Users
INSERT INTO `users` (`id`, `full_name`, `email`, `password_hash`, `role`, `student_id`, `department`, `phone`) VALUES
(1, 'System Administrator', 'admin@smartcampus.edu', '$2y$10$bN6rsKiD7tY6BrRMp5NouOOf2e4jdVGwWhVj/3GWpa7hWZQAk0tCe', 'admin', 'ADM-2026-01', 'Information Technology Services', '+1 (555) 019-2834'),
(2, 'Alex Carter (Student)', 'student@smartcampus.edu', '$2y$10$AzjoSt1pX5L03n3J0mHGiudWgPSPNYjSYjZoF6VRPPE9rIOvn.bgC', 'student', 'CS-2024-8842', 'Computer Science & Engineering', '+1 (555) 014-9921'),
(3, 'Prof. Evelyn Reed', 'organizer@smartcampus.edu', '$2y$10$bN6rsKiD7tY6BrRMp5NouOOf2e4jdVGwWhVj/3GWpa7hWZQAk0tCe', 'organizer', 'FAC-4402', 'Artificial Intelligence & Robotics Lab', '+1 (555) 018-7733'),
(4, 'Sarah Connor', 'sarah.c@smartcampus.edu', '$2y$10$AzjoSt1pX5L03n3J0mHGiudWgPSPNYjSYjZoF6VRPPE9rIOvn.bgC', 'student', 'DS-2023-1092', 'Data Science & Analytics', '+1 (555) 012-3456'),
(5, 'Marcus Vance', 'marcus.v@smartcampus.edu', '$2y$10$AzjoSt1pX5L03n3J0mHGiudWgPSPNYjSYjZoF6VRPPE9rIOvn.bgC', 'student', 'SE-2025-5510', 'Software Engineering', '+1 (555) 017-6543');

-- Insert Sample Venues
INSERT INTO `venues` (`id`, `venue_name`, `building`, `capacity`, `status`, `location_details`, `amenities`) VALUES
(1, 'Grand Central Auditorium', 'Newton Science Complex, Block A', 500, 'available', 'Ground Floor, Main Entrance with dual stage screens and wheelchair access.', 'Dual 4K Laser Projectors, Dolby Atmos Audio, Wireless Mics, Central AC, High-Speed Campus WiFi'),
(2, 'Advanced Computing Lab 2', 'Turing Technology Tower', 60, 'available', '3rd Floor, West Wing. 60 High-end RTX 4080 workstations installed.', '60 Workstations, Gigabit Ethernet, Dual Overhead Monitors, Smart Podium'),
(3, 'Innovation Hub & Makerspace', 'Edison Engineering Pavilion', 120, 'available', '2nd Floor, Mezzanine Level. Modular seating with 3D printing and prototyping bay.', 'Modular Tables, Mobile Whiteboards, Presentation Screen, 3D Printers, Soldering Stations'),
(4, 'Seminar Hall 402', 'Babbage Academic Hall', 150, 'available', '4th Floor, Room 402. Tiered lecture amphitheater setup.', 'Smart Board, High-Gain Microphones, Ergonomic Desks, Live Streaming Rig'),
(5, 'Executive Conference Hall', 'Administration Building', 40, 'maintenance', '1st Floor, Boardroom Suite. Currently undergoing audiovisual upgrade.', 'Video Conferencing Rig, Conference Mic Array, Executive Recliners');

-- Insert Sample Events & Workshops
INSERT INTO `events` (`id`, `title`, `category`, `event_type`, `short_description`, `description`, `venue_id`, `start_datetime`, `end_datetime`, `banner_image`, `status`, `rules`, `speakers`, `agenda`, `organizer_name`, `max_capacity`, `created_by`) VALUES
(1, 'Annual Campus Hackathon 2026: Code the Future', 'Programming', 'event', 'A thrilling 24-hour hackathon bringing together students to solve real-world problems using AI, Web, and Cloud technologies.', 'Welcome to the premier university software hackathon of the academic year! Over 24 hours, teams of 2-4 developers, designers, and innovators will brainstorm, prototype, and pitch groundbreaking solutions. Mentor office hours, midnight pizza, energy drinks, and exciting sponsor tracks from top tech companies included.', 1, DATE_ADD(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL 6 DAY), 'hackathon.jpg', 'approved', '1. Teams must consist of 2 to 4 registered university students.\n2. All code repositories must be initiated after kickoff.\n3. Pre-built libraries and open-source packages are permitted.\n4. Strict adherence to the Campus Code of Conduct is mandatory.', 'Sarah Chen (Lead Architect, OpenAI Contributor)\nDavid Ross (Head of Engineering, CloudScale)', '09:00 AM - Check-in & Team Registration\n10:30 AM - Opening Keynote & Problem Statements Reveal\n12:00 PM - Hacking Commences\n03:00 PM - Mentor Lightning Round\n12:00 AM - Midnight Pizza & Mini-games\n08:00 AM - Code Freeze & Project Submission\n10:00 AM - Live Demos & Award Ceremony', 'Campus Technical Council', 350, 1),

(2, 'Mastering Generative AI & LLMs in Production', 'Data Science', 'workshop', 'Hands-on masterclass building production-grade RAG pipelines, fine-tuning transformers, and deploying scalable LLM APIs.', 'In this intensive 4-hour technical workshop, attendees will gain direct practical experience with modern Large Language Models. You will build a Retrieval-Augmented Generation (RAG) assistant using LangChain, Vector Databases, and Python. Every student gets access to a dedicated cloud GPU instance for the duration of the session.', 2, DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 3 DAY), INTERVAL 4 HOUR), 'genai.jpg', 'approved', '1. Bring your laptop with Python 3.10+ installed or use our lab workstations.\n2. Basic familiarity with Python and REST APIs is recommended.\n3. GitHub account required for cloud sandbox authorization.', 'Dr. Evelyn Reed (Director, Campus AI Lab)\nKavita Patel (Staff ML Engineer)', '02:00 PM - Introduction to Modern Vector Stores & Embeddings\n02:45 PM - Hands-on Lab: Indexing Campus Academic Documents\n04:00 PM - Short Coffee Break & Networking\n04:15 PM - Building Hybrid Search and Guardrails\n05:30 PM - Deployment to Cloud Endpoints & Q&A', 'AI & Machine Learning Club', 60, 3),

(3, 'Modern UI/UX Design Systems with Figma', 'Design', 'workshop', 'Learn how top tech organizations create consistent, accessible, and scalable design tokens and component libraries.', 'Great products rely on solid design systems. This interactive workshop walks you through Figma component variants, responsive autolayout, design tokens, color contrast accessibility (WCAG AAA), and smooth design-to-code handoffs for Tailwind CSS.', 3, DATE_ADD(NOW(), INTERVAL 7 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 7 DAY), INTERVAL 3 HOUR), 'uiux.jpg', 'approved', '1. Free Figma account required.\n2. Bring a laptop with a modern web browser.\n3. No prior coding experience required; beginner-friendly!', 'Leo Martinez (Senior Product Designer, Stripe Alum)', '10:00 AM - Foundations of Modern Atomic Design\n11:00 AM - Hands-on: Building a Token-driven UI Kit\n12:15 PM - Interactive Prototype Testing & Handoff Strategies', 'Creative Design Guild', 80, 3),

(4, 'Full-Stack Modern Web with React & Node.js', 'Programming', 'workshop', 'Build and deploy a full-stack reactive web app with authentication, state management, and real-time database queries.', 'Accelerate your web engineering skills! We cover ES6+ syntax, React Hooks, RESTful Express server architecture, and MySQL connectivity using prepared transactions.', 2, DATE_ADD(NOW(), INTERVAL 10 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 10 DAY), INTERVAL 5 HOUR), 'react_node.jpg', 'approved', '1. Basic knowledge of HTML, CSS, and JavaScript.\n2. Install Node.js LTS and VS Code on your machine.', 'Jordan Lee (Full Stack Lead, Vercel Community)', '01:00 PM - React 19 State & Effect Paradigms\n02:30 PM - Node/Express Clean Route Controller Patterns\n04:00 PM - Deploying to Production & Live Debugging', 'Google Developer Student Club', 60, 1),

(5, 'Cybersecurity Defensive Blue Teaming Workshop', 'Cybersecurity', 'workshop', 'Simulate real cyber attacks and learn proactive incident response, packet inspection, and server hardening.', 'Step into the shoes of an information security defensive analyst. Learn how network intrusion detectors work, how to trace malicious SQL injections and cross-site scripting attempts, and how to harden Apache and Linux servers against zero-day exploits.', 4, DATE_ADD(NOW(), INTERVAL 14 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 14 DAY), INTERVAL 4 HOUR), 'cybersecurity.jpg', 'approved', '1. Bring a laptop with VirtualBox or VMware Workstation.\n2. Pre-configured ISO files will be distributed via campus network.', 'Captain Nathan Drake (Certified Ethical Hacker & InfoSec Specialist)', '11:00 AM - Attack Surface Mapping & Reconnaissance\n12:15 PM - Live Capture the Flag (CTF) Defense Challenge\n02:30 PM - Debriefing, Threat Hunting & Remediation', 'Cyber Defense Society', 100, 1),

(6, 'Digital Product Marketing & Growth Hacking', 'Marketing', 'workshop', 'Discover the exact playbook used by Silicon Valley startups to acquire their first 10,000 active users with zero budget.', 'A high-impact workshop exploring customer acquisition channels, conversion rate optimization (CRO), behavioral email sequences, and organic growth loop design.', 3, DATE_ADD(NOW(), INTERVAL 18 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 18 DAY), INTERVAL 3 HOUR), 'marketing.jpg', 'approved', '1. Open to all campus disciplines (Engineering, Business, Arts).\n2. Note-taking materials recommended.', 'Alicia Gomez (Growth Consultant & Angel Investor)', '02:00 PM - Funnel Economics & CAC vs LTV\n03:15 PM - Organic Search & Viral Referral Mechanics\n04:30 PM - Interactive Case Studies & Pitch Critiques', 'Campus Entrepreneurship Cell', 90, 3),

(7, 'Emerging Quantum Computing & Cryptography', 'Data Science', 'event', 'A symposium featuring leading university researchers on qubit stability, Shor algorithm implications, and post-quantum encryption.', 'Join our keynote physics and computer science panels as we examine the next decade of quantum hardware breakthroughs and the cryptographic transitions needed to protect global networks.', 1, DATE_ADD(NOW(), INTERVAL 22 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 22 DAY), INTERVAL 6 HOUR), 'quantum.jpg', 'approved', '1. Open to all students and faculty.\n2. Pre-registration required for guaranteed seating badge.', 'Prof. Arthur Sterling (National Quantum Institute)\nDr. Helena Croft (Lead Cryptographer)', '10:00 AM - Keynote Address: The Quantum Frontier\n11:30 AM - Panel Discussion: NIST Post-Quantum Standards\n01:30 PM - Student Research Poster Showcase', 'Department of Physics & Computing', 300, 1),

(8, 'Campus Career Fair & Tech Networking Mixer', 'Career', 'event', 'Over 40 top employer booths, resume critiques, on-the-spot speed interviews, and direct networking with HR leaders.', 'Prepare your resumes and dress in business casual! The annual campus career fair connects undergraduate and postgraduate students with internship and full-time hiring managers from engineering, finance, biotech, and product consulting firms.', 1, DATE_ADD(NOW(), INTERVAL 28 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 28 DAY), INTERVAL 8 HOUR), 'career.jpg', 'approved', '1. Valid Student ID card required at entry gates.\n2. Bring at least 10 printed copies of your resume.', 'Over 40 Campus Recruiting Leads from Fortune 500 Tech Giants', '09:00 AM - Doors Open & Check-in Badge Pickup\n10:00 AM - Fireside Chat: Standing Out in Technical Interviews\n11:00 AM - Open Exhibition & Resume Drop Booths\n03:00 PM - Invitation-Only Speed Interviews', 'University Career Development Center', 500, 1),

(9, 'Robotics Autonomous Navigation with ROS2', 'Robotics', 'workshop', 'Learn LiDAR mapping, SLAM algorithms, and obstacle avoidance using Robot Operating System 2 (ROS2) in simulated 3D environments.', 'Hands-on laboratory tutorial configuring autonomous navigation stacks on differential drive rovers. Attendees will simulate robot paths using Gazebo and RViz.', 3, DATE_ADD(NOW(), INTERVAL 12 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 12 DAY), INTERVAL 4 HOUR), 'robotics.jpg', 'approved', '1. Laptop with Ubuntu 22.04 or Docker installed.\n2. Intermediate C++ or Python experience recommended.', 'Prof. Evelyn Reed & Robotics Team Leads', '01:00 PM - ROS2 Nodes, Topics, and Services Recap\n02:15 PM - 2D LiDAR SLAM & Costmap Configuration\n04:00 PM - Live Hardware Demonstration with TurtleBot4', 'Robotics Club', 70, 3),

(10, 'Campus Esports Championship - League of Innovators', 'Gaming', 'event', 'University tournament featuring inter-departmental gaming squads competing for the annual trophy and scholarship prize pool.', 'Spectators and cheer squads welcome! Live stage shoutcasting, high-refresh-rate gaming stations, and food trucks stationed outside the auditorium.', 1, DATE_ADD(NOW(), INTERVAL 35 DAY), DATE_ADD(DATE_ADD(NOW(), INTERVAL 35 DAY), INTERVAL 10 HOUR), 'esports.jpg', 'pending', '1. Department team roster registration closes 7 days before event.\n2. Standard tournament competitive guidelines apply.', 'Campus Gaming League Executive Committee', '11:00 AM - Opening Matches & Group Stage\n03:00 PM - Semi-finals Stream\n06:30 PM - Grand Finals & Trophy Presentation', 'Campus Sports & Recreation Society', 400, 1);

-- Insert Sample Registrations
INSERT INTO `registrations` (`id`, `event_id`, `user_id`, `registration_date`, `ticket_code`, `status`, `notes`) VALUES
(1, 1, 2, DATE_SUB(NOW(), INTERVAL 2 DAY), 'TKT-2026-HACK-8842', 'registered', 'Confirmed attendee for Hackathon 2026'),
(2, 2, 2, DATE_SUB(NOW(), INTERVAL 1 DAY), 'TKT-2026-GENAI-8842', 'registered', 'Confirmed attendee for Generative AI Workshop'),
(3, 3, 4, DATE_SUB(NOW(), INTERVAL 3 DAY), 'TKT-2026-FGD-1092', 'registered', 'Confirmed attendee for Figma Workshop'),
(4, 1, 4, DATE_SUB(NOW(), INTERVAL 2 DAY), 'TKT-2026-HACK-1092', 'registered', 'Team member of DataBytes'),
(5, 5, 5, DATE_SUB(NOW(), INTERVAL 1 DAY), 'TKT-2026-CYBER-5510', 'registered', 'Confirmed attendee for Cybersecurity Workshop');

-- Insert Sample Broadcasts
INSERT INTO `broadcasts` (`id`, `recipient_group`, `subject`, `message`, `scheduled_at`, `sent_at`, `created_by`, `created_at`) VALUES
(1, 'all', 'Welcome to the New Smart Campus Event & Workshop Portal!', 'We are delighted to launch our centralized campus event discovery platform. Students and faculty can now browse upcoming technical workshops, reserve seats, and access digital verification tickets instantly.', NOW(), NOW(), 1, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(2, 'students', 'Hackathon 2026 Registration Now Open', 'Registrations for the Annual Campus Hackathon are filling up rapidly. Secure your slot and review team requirements on the event details page.', NOW(), NOW(), 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 'organizers', 'Venue Booking Reminders for Spring Semester', 'Please submit your venue reservation requests at least 7 days prior to proposed workshop dates to allow adequate audiovisual testing.', NOW(), NOW(), 1, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Insert Sample Contact Messages
INSERT INTO `contact_messages` (`id`, `name`, `email`, `subject`, `message`, `status`, `created_at`) VALUES
(1, 'Emily Watson', 'emily.w@smartcampus.edu', 'Inquiry regarding Hackathon Hardware track', 'Can teams bring their own custom microcontrollers (Raspberry Pi / Arduino) for the IoT track?', 'read', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, 'Michael Chang', 'm.chang@smartcampus.edu', 'Volunteer Opportunities for Career Fair', 'I would like to volunteer for the student guide desk during the upcoming career fair.', 'unread', NOW());
