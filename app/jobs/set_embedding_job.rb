class SetEmbeddingJob < ApplicationJob
  retry_on RubyLLM::RateLimitError, wait: 3.seconds, attempts: 10 do |job, error|
    SolidQueue::FailedExecution.joins(:job).where(solid_queue_jobs: { active_job_id: job.job_id }).destroy_all
  end
  queue_as :default

  def perform(post)
    embedding = RubyLLM.embed("Post's content: #{post.content}. Date: #{post.date}")
    post.update(embedding: embedding.vectors)
  end
end
