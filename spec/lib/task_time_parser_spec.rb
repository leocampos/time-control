require 'spec_helper'

module TaskTimeParserSpecHelper
  def parse(text)
    @parser.parse(text)
  end
end

describe TimeControl::Parser::TaskTimeParser do
  include TaskTimeParserSpecHelper
  
  before(:each) do
    @parser = TimeControl::Parser::TaskTimeParser.new
  end
  
  it 'should parse "reunião com leo" as a name' do
    debugger
    parse('reunião com leo').should_not be_nil
  end
end