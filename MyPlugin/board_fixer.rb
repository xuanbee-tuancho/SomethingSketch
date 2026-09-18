module MyPlugin
  module BoardFixer
    module_function

    def fix(entity)
      changes = []

      if entity.name.to_s.strip.empty?
        entity.name = 'Board'
        changes << 'Đã đặt tên mặc định: Board.'
      end

      changes
    end
  end
end
