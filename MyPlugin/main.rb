module MyPlugin
  require File.join(ROOT, 'MyPlugin', 'board_checker')
  require File.join(ROOT, 'MyPlugin', 'board_fixer')
  require File.join(ROOT, 'MyPlugin', 'block_creator')
  require File.join(ROOT, 'MyPlugin', 'board_info_checker')
  require File.join(ROOT, 'MyPlugin', 'board_naming_dialog')
  require File.join(ROOT, 'MyPlugin', 'report')

  module Main
    module_function

    def selected_boards
      selection = Sketchup.active_model.selection
      selection.select { |entity| BoardChecker.board?(entity) }
    end

    def selected_board
      selected_boards.first
    end

    def check_selected_board
      boards = selected_boards
      if boards.empty?
        UI.messagebox('Hãy chọn ít nhất một Group hoặc Component đại diện cho tấm ván.')
        return
      end

      results = boards.map { |board| BoardChecker.check(board) }
      UI.messagebox(Report.format_results(results))
    end

    def show_selected_board_info
      boards = selected_boards
      if boards.empty?
        UI.messagebox('Hãy chọn ít nhất một Group hoặc Component đại diện cho tấm ván.')
        return
      end

      infos = boards.map { |board| BoardInfoChecker.inspect(board) }
      UI.messagebox(BoardInfoChecker.format(infos))
    end

    def fix_selected_board
      boards = selected_boards
      if boards.empty?
        UI.messagebox('Hãy chọn ít nhất một Group hoặc Component đại diện cho tấm ván.')
        return
      end

      model = Sketchup.active_model
      model.start_operation('Fix selected board', true)

      begin
        changes = boards.flat_map { |board| BoardFixer.fix(board) }
        model.commit_operation
        UI.messagebox(Report.format_changes(changes))
      rescue StandardError
        model.abort_operation
        raise
      end
    end
  end

  menu = UI.menu('Extensions')
  menu.add_item('Check Selected Board') { Main.check_selected_board }
  menu.add_item('Show Board Name & Info') { Main.show_selected_board_info }
  menu.add_item('Board Name Manager') { BoardNamingDialog.show }
  menu.add_item('Fix Selected Board') { Main.fix_selected_board }
  menu.add_item('Create Dimensioned Block') { BlockCreator.create }
end
