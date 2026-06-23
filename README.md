# Conversights

> AI SaaS that turns YouTube comments into a consumer-insights dashboard for product teams

**Role:** Lead developer in a team of 4, Le Wagon final bootcamp project

## What it does
Enter the name of your product and its brand in Conversights. It scrapes the comments, embeds them, and builds a live insights Dashboard with 6 cards : 3 key themes, pain points, strengths, suggested improvements, and an overall sentiment score. A built-in RAG chat lets you interrogate the comment corpus in natural language.

## Stack
Ruby on Rails 7.1 · PostgreSQL + pgvector · Hotwire (Turbo/Stimulus) · RubyLLM + OpenAI (gpt-4o-mini) · SolidQueue · Devise · Bootstrap 5

## Architecture highlights
- **RAG pipeline:** comments embedded into pgvector (1536-dim), retrieved as context for both the chat and dashboard generation.
- **Async by default (SolidQueue):** scraping, embedding, dashboard refresh and incremental enrichment run in background jobs; results stream to the UI over Turbo Streams.
- **Incremental enrichment:** new comments are fetched and re-embedded on defined triggers (refresh, chat visits, staleness > 1h), so insights stay current without full re-scrapes.
