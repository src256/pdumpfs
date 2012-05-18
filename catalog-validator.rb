load 'pdumpfs'
class CatalogValidator
  def initialize (source_filename)
    @source_filename  = source_filename
    @has_error = false
  end

  def read_file_with_numbering (filename)
    content = ''
    File.open(filename).each_with_index {|line, idx|
      lineno = idx + 1
      content << line.gsub(/\b_\(/, "_[#{lineno}](")
    }
    content
  end

  def collect_messages (content)
    messages = []
    while content.sub!(/\b_\[(\d+)\]\((".*?").*?\)/m, "")
      lineno  = $1.to_i
      message = eval($2)
      messages.push([lineno, message])
    end
    messages
  end

  def validate
    $catalog_messages or return
    content = read_file_with_numbering(@source_filename)
    messages = collect_messages(content)
    messages.each {|lineno, message|
      translated_message = $catalog_messages[message]
      if not translated_message
        printf "%s:%d: %s\n", @source_filename, lineno, message.inspect
        @has_error = true
      elsif message.count("%") != translated_message.count("%")
        printf "%s:%d: %s => # of %% mismatch.\n",
          @source_filename, lineno, message.inspect, translated_message
        @has_error = true
      end
    }
  end

  def ok?
    not @has_error
  end
end

if ARGV.length < 2
  puts "usage: ruby catalog-validator.rb <catalog> <source...>"
  exit
end

include GetText
catalog_file = ARGV.shift
load_catalog(catalog_file)

ok = true
ARGV.each {|source_file|
  validator = CatalogValidator.new(source_file)
  validator.validate
  ok = (ok and validator.ok?)
}
if ok then exit else exit(1) end
