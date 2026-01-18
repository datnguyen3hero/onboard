module Entities
  class AlertEntity < Grape::Entity
    expose :id, :title, :body, :active, :alert_type, :published_at
    expose :severity, :status, :acknowledged_at, :resolved_at
    expose :is_overdue do |alert|
      alert.overdue?
    end
  end
end
