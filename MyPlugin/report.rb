module MyPlugin
  module Report
    module_function

    def format(issues)
      return 'Không phát hiện lỗi.' if issues.empty?

      "Các vấn đề phát hiện được:\n\n" + issues.map { |issue| "- #{issue}" }.join("\n")
    end

    def format_results(results)
      issue_count = results.sum(&:length)
      return 'Không phát hiện lỗi.' if issue_count.zero?

      sections = results.each_with_index.filter_map do |issues, index|
        next if issues.empty?

        "Tấm ván #{index + 1}:\n" + issues.map { |issue| "- #{issue}" }.join("\n")
      end

      "Đã kiểm tra #{results.length} tấm ván.\n\n" + sections.join("\n\n")
    end

    def format_changes(changes)
      return 'Không có lỗi an toàn nào để tự sửa.' if changes.empty?

      changes.join("\n")
    end
  end
end
