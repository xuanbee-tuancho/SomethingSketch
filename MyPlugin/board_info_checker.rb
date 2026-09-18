module MyPlugin
  module BoardInfoChecker
    module_function

    def inspect(entity)
      bounds = entity.bounds
      dimensions = [bounds.width, bounds.depth, bounds.height]

      {
        name: entity.name.to_s.strip,
        name_valid: !entity.name.to_s.strip.empty?,
        type: entity.class.name.split('::').last,
        width: bounds.width,
        depth: bounds.depth,
        height: bounds.height,
        thickness: dimensions.min,
        material: entity.material ? entity.material.name : 'Chưa có'
      }
    end

    def format(infos)
      sections = infos.each_with_index.map do |info, index|
        name = info[:name].empty? ? '(chưa đặt tên)' : info[:name]
        name_status = info[:name_valid] ? 'Hợp lệ' : 'Thiếu tên'

        <<~TEXT.strip
          Tấm ván #{index + 1}
          Tên: #{name}
          Kiểm tra tên: #{name_status}
          Loại: #{info[:type]}
          Ngang: #{format_length(info[:width])}
          Sâu: #{format_length(info[:depth])}
          Cao: #{format_length(info[:height])}
          Độ dày ước tính: #{format_length(info[:thickness])}
          Vật liệu: #{info[:material]}
        TEXT
      end

      "Đã đọc thông tin #{infos.length} tấm ván.\n\n" + sections.join("\n\n")
    end

    def format_length(length)
      "#{length.to_mm.round(2)} mm"
    end
  end
end
