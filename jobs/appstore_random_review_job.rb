require_relative '../lib/infrastructure/project_manager'
require_relative '../lib/infrastructure/project_model'
require_relative '../lib/appstore/review_service'
require_relative '../lib/appstore/review_model'

LATEST_REVIEW_COUNT = 15

SCHEDULER.every '15s', :first_in => 0 do |job|
  project_manager = Infrastructure::ProjectManager.new
  projects = project_manager.obtain_all_projects.select { |project|
    project.appstore_id != nil
  }
  projects.each do |project|
    service = AppStore::ReviewService.new
    reviews = service.obtain_reviews_for_app_id(project.appstore_id)

    # We work only with latest 15 reviews
    random_review = reviews[0..LATEST_REVIEW_COUNT - 1].sample
    if random_review != nil
        widget_name = "appstore_review_#{project.appstore_id}"
        send_event(widget_name, {
                                  'author_name' => random_review.author_name,
                                  'version' => random_review.version,
                                  'text' => random_review.text,
                                  'title' => random_review.title,
                                  'rating' => random_review.rating
                                })
      end
  end
end