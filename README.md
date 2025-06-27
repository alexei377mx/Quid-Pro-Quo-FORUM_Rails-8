# 📻 Quid Pro Quo FORUM

This is a Ruby on Rails 8 web application built as a community-driven platform. It supports user-generated posts, comments with threading, content moderation, real-time interactions, contact messaging, and even a radio stream feature.

## 🚀 Features

* **User Management**: Sign up, login, roles (`user`, `admin`), and ban functionality.
* **Posts**: Users can create, read, and manage blog-style posts with categories and visit counters.
* **Comments**: Nested/threaded comments with support for user reactions (likes, etc.).
* **Reports**: Users can report content (posts or comments), with admin review workflow.
* **Logs**: Internal user activity tracking system for auditing.
* **Contact Form**: Allows users to send messages directly to the platform administrators.
* **Radio Streaming**: Includes a feature to stream online radio stations.
* **File Uploads**: Integrated Active Storage for managing uploads.

## 🗃️ Database Schema Overview

The app uses **PostgreSQL** and supports:

* `users`: Account management with roles and authentication.
* `posts`: Main content objects with title, content, category, and visit tracking.
* `comments`: Threaded discussions under posts, including soft deletion by admins.
* `comment_reactions`: Tracks user reactions to comments.
* `reports`: Tracks content flagged by users for moderation.
* `logs`: Internal auditing of actions performed by users.
* `contact_messages`: Messages sent via a contact form.
* `radios`: Simple entries to store titles and streaming URLs.
* Active Storage tables (`active_storage_*`) for file uploads and attachments.

## 🛠️ Getting Started

### Requirements

* Ruby 3.3+ (or compatible with Rails 8)
* Rails 8.0+
* PostgreSQL

### Setup Instructions

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo

bundle install

# Set up the database
bin/rails db:setup

# Run the server
bin/rails server
```

### Running Tests

```bash
bin/rails test
```

## 🛡️ Security & Moderation

* Users can report inappropriate content.
* Admins can soft-delete posts and comments (`deleted_by_admin`).
* Banned users are restricted from accessing the platform.

## 📦 Technologies Used

* **Ruby on Rails 8**
* **PostgreSQL**
* **Active Storage**
* **BCrypt** for password hashing

## 📬 Contact

For questions or feedback, please create an issue or send a message via the contact form.
