module MyPlugin
  module BoardChecker
    module_function

    def board?(entity)
      entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
    end

    def check(entity)
      issues = []
      issues << 'Đối tượng đã bị xóa hoặc không còn hợp lệ.' unless entity.valid?
      issues << 'Tấm ván chưa có tên.' if entity.name.to_s.strip.empty?
      issues << 'Tấm ván đang bị khóa.' if entity.respond_to?(:locked?) && entity.locked?
      issues << 'Tấm ván chưa có vật liệu.' if entity.material.nil?

      bounds = entity.bounds
      issues << 'Kích thước tấm ván không hợp lệ.' if bounds.width <= 0 || bounds.height <= 0 || bounds.depth <= 0
      issues
    end
  end
end
