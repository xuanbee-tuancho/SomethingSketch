module MyPlugin
  module BlockCreator
    module_function

    def create
      values = UI.inputbox(
        ['Chiều ngang', 'Chiều sâu', 'Chiều cao'],
        ['1000 mm', '500 mm', '18 mm'],
        'Tạo khối theo kích thước'
      )
      return unless values

      dimensions = parse_dimensions(values)
      unless dimensions
        UI.messagebox('Vui lòng nhập kích thước ngang, sâu, cao lớn hơn 0.')
        return
      end

      model = Sketchup.active_model
      model.start_operation('Create dimensioned block', true)

      begin
        group = build_group(model, dimensions)
        model.commit_operation
        model.selection.clear
        model.selection.add(group)
      rescue StandardError
        model.abort_operation
        raise
      end
    end

    def parse_dimensions(values)
      dimensions = values.map { |value| value.to_s.to_l }
      return nil unless dimensions.all? { |value| value && value > 0 }

      dimensions
    rescue StandardError
      nil
    end

    def build_group(model, dimensions)
      x, y, z = dimensions
      entities = model.active_entities
      group = entities.add_group
      group.name = 'Dimensioned Block'
      group.entities.add_box(ORIGIN, x, y, z)

      offset = [x, y, z].min / 2.0
      offset = 1.inch if offset <= 0
      add_axis_marker(group.entities, Geom::Point3d.new(0, -offset, 0), Geom::Point3d.new(x, -offset, 0), 'Ngang')
      add_axis_marker(group.entities, Geom::Point3d.new(x + offset, 0, 0), Geom::Point3d.new(x + offset, y, 0), 'Sâu')
      add_axis_marker(group.entities, Geom::Point3d.new(x + offset, y + offset, 0), Geom::Point3d.new(x + offset, y + offset, z), 'Cao')

      group
    end

    def add_axis_marker(entities, start_point, end_point, label)
      entities.add_line(start_point, end_point)

      midpoint = Geom::Point3d.new(
        (start_point.x + end_point.x) / 2.0,
        (start_point.y + end_point.y) / 2.0,
        (start_point.z + end_point.z) / 2.0
      )
      text_group = entities.add_group
      text_group.transformation = Geom::Transformation.translation(midpoint - ORIGIN)
      text_group.entities.add_3d_text(label, TextAlignCenter, 'Arial', true, false, 1.inch, 0.1, 0, true, 0)
    end
  end
end
