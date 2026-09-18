module MyPlugin
  module BoardNamingDialog
    module_function

    def show
      if @dialog && @dialog.visible?
        @dialog.bring_to_front
        return
      end

      @dialog = UI::HtmlDialog.new(
        dialog_title: 'Đặt tên tấm ván',
        preferences_key: 'MyPlugin.BoardNamingDialog',
        scrollable: true,
        resizable: true,
        width: 420,
        height: 520,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      @dialog.set_on_closed { @dialog = nil }
      add_callbacks
      refresh
      @dialog.show
    end

    def add_callbacks
      @dialog.add_action_callback('add_name') do |_dialog, name|
        add_name(name)
      end

      @dialog.add_action_callback('apply_name') do |_dialog, name|
        apply_name(name)
      end
    end

    def add_name(name)
      name = name.to_s.strip
      return if name.empty? || @names&.include?(name)

      @names ||= []
      @names << name
      refresh
    end

    def apply_name(name)
      boards = Main.selected_boards
      if boards.empty?
        UI.messagebox('Hãy chọn ít nhất một Group hoặc Component trước khi đặt tên.')
        return
      end

      name = name.to_s.strip
      return if name.empty?

      model = Sketchup.active_model
      model.start_operation('Name selected boards', true)

      begin
        boards.each { |board| board.name = name }
        model.commit_operation
        UI.messagebox("Đã đặt tên #{boards.length} tấm ván: #{name}")
      rescue StandardError
        model.abort_operation
        raise
      end
    end

    def refresh
      @names ||= []
      @dialog.set_html(html)
    end

    def html
      names_html = @names.map do |name|
        escaped_name = escape_html(name)
        "<button class=\"name-button\" data-name=\"#{escaped_name}\" onclick=\"applyName(this.dataset.name)\">#{escaped_name}</button>"
      end.join

      <<~HTML
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: Arial, sans-serif; margin: 18px; color: #3D321A; background: #FFF7D6; }
            h2 { margin: 0 0 8px; font-size: 20px; }
            p { color: #75602A; margin: 0 0 16px; }
            .add-row { display: flex; gap: 8px; margin-bottom: 18px; }
            input { flex: 1; min-width: 0; padding: 9px; font-size: 14px; color: #3D321A; background: #FFFBEA; border: 1px solid #D9BF68; }
            button { cursor: pointer; padding: 9px 12px; font-size: 14px; color: #3D321A; background: #E8C75A; border: 1px solid #C8A83D; }
            .name-list { display: flex; flex-direction: column; gap: 7px; }
            .name-button { text-align: left; background: #FFF0B3; border: 1px solid #D9BF68; }
            .name-button:hover { background: #F4D982; }
            .empty { color: #8A743B; font-style: italic; }
          </style>
        </head>
        <body>
          <h2>Đặt tên tấm ván</h2>
          <p>Nhập tên mới rồi bấm Add. Sau đó chọn ván trong SketchUp và bấm tên muốn gán.</p>
          <div class="add-row">
            <input id="nameInput" type="text" placeholder="Tên tấm ván">
            <button onclick="addName()">Add</button>
          </div>
          <div class="name-list">
            #{names_html.empty? ? '<div class="empty">Chưa có tên nào.</div>' : names_html}
          </div>
          <script>
            function addName() {
              const input = document.getElementById('nameInput');
              const name = input.value.trim();
              if (!name) return;
              sketchup.add_name(name);
              input.value = '';
            }

            function applyName(name) {
              sketchup.apply_name(name);
            }

            document.getElementById('nameInput').addEventListener('keydown', function(event) {
              if (event.key === 'Enter') addName();
            });
          </script>
        </body>
        </html>
      HTML
    end

    def escape_html(value)
      value.to_s
        .gsub('&', '&amp;')
        .gsub('<', '&lt;')
        .gsub('>', '&gt;')
        .gsub('"', '&quot;')
        .gsub("'", '&#39;')
    end
  end
end
