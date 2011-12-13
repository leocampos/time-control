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
    parse('reunião com leo').should_not be_nil
    parse('com uso do + no meio do texto').should_not be_nil
    parse('com uso do +5 no meio do texto').should_not be_nil
    parse('com uso do +5m no meio do texto').should be_nil
    
    parse('com uso do +5m').should_not be_nil
    parse('com uso do 16').should_not be_nil
    parse('com uso do 25').should_not be_nil #Passa a considerar tudo como nome da Task
  end
end