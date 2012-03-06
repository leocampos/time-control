# coding: utf-8

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

  context 'ao chamar parse' do
    context 'contendo #' do
      it 'deveria ser apenas uma string se dentro de "" ou \'\'' do
        nodes = parse('"#tag1 #tag_nova2"')
        nodes.name.text_value.should == '#tag1 #tag_nova2'
      end
      
      it 'deveria retornar nulo se comecar #' do
        nodes = parse('#tag1 #tag_nova2')
        nodes.should be_nil
      end
      
      it 'deveria retornar as tags se vierem depois do nome' do
        nodes = parse('nome da task #tag1 #tag_nova2')
        
        nodes.hashes.striped_value.should == '#tag1 #tag_nova2'
        nodes.name.text_value.should == 'nome da task'
      end
      
      it 'deveria retornar nome, hashes e horarios' do
        nodes = parse("deploy PST #deploy #work #dst 07:30-08:20")
        
        nodes.should be
      end
    end
    
    it 'com string vazia deveria retornar nulo' do
      parse('').should be_nil
    end

    context 'apenas com nome da task' do
      it 'deveria capturar o valor' do
        valor = parse('teste')
        valor.should_not be_nil
        valor.text_value.should == 'teste'

        parse('com uso do + no meio do texto').should_not be_nil
        parse('com uso do +5 no meio do texto').should_not be_nil
        parse('com uso do +5m no meio do texto').should be_nil
        
        parse('renião sala').should be

        parse('com uso do +5m').should_not be_nil
        parse('com uso do 16').should_not be_nil
        parse('com uso do 25').should_not be_nil #Passa a considerar tudo como nome da Task
      end
    end
    
    context 'using "" or '' to scape special characters' do
      it 'should consider everything inside as task name' do
        nodes = parse("'meeting at room 16'")
        nodes.should_not be_nil
        nodes.name.text_value.should == 'meeting at room 16'
        
        nodes = parse('"meeting at room 16"')
        nodes.should_not be_nil
        nodes.name.text_value.should == 'meeting at room 16'
        
        nodes = parse('"meeting at \'the human resources\' room 16"')
        nodes.should_not be_nil
        nodes.name.text_value.should == "meeting at 'the human resources' room 16"
        
        nodes = parse('"reading spreadsheet 1601-19" -30m')
        nodes.should_not be_nil
        nodes.name.text_value.should == 'reading spreadsheet 1601-19'
        nodes.time_setting.striped_value.should == '-30m'
      end
    end

    context 'apenas com horario' do
      it 'deveria ser considerado o nome da task' do
        parse('+5m').should be
        parse('16').should be
        parse('2310').should be
        parse('1615-1530').should be
        parse('1615-1530').text_value.should == '1615-1530'
      end
    end

    context 'com nome e horário da task' do
      it 'deveria poder recuperar nome e horario' do
        nodes = parse('lendo emails -15m')
        nodes.name.text_value.should == 'lendo emails'
        nodes.time_setting.striped_value.should == '-15m'
        
        nodes = parse('almoço 13')
        nodes.name.text_value.should == 'almoço'
        nodes.time_setting.striped_value.should == '13'

        nodes = parse('almoço 2 13-14')
        nodes.name.text_value.should == 'almoço 2'
        nodes.time_setting.striped_value.should == '13-14'

        nodes = parse('almoço +3 1309-14')
        nodes.name.text_value.should == 'almoço +3'
        nodes.time_setting.striped_value.should == '1309-14'
        
        nodes = parse('almoço +3 13:09-14')
        nodes.name.text_value.should == 'almoço +3'
        nodes.time_setting.striped_value.should == '13:09-14'

        nodes = parse('reunião com chefe 1001-1120')
        nodes.name.text_value.should == 'reunião com chefe'
        nodes.time_setting.striped_value.should == '1001-1120'
        
        #Testing limits
        nodes = parse('lunch 23')
        nodes.name.text_value.should == 'lunch'
        nodes.time_setting.striped_value.should == '23'
        
        nodes = parse('lunch 24')
        nodes.name.text_value.should == 'lunch 24'
        nodes.time_setting.should be_empty
        
        nodes = parse('lunch 2359')
        nodes.name.text_value.should == 'lunch'
        nodes.time_setting.striped_value.should == '2359'
        
        nodes = parse('lunch 2360')
        nodes.name.text_value.should == 'lunch 2360'
        nodes.time_setting.should be_empty
        
        nodes = parse('lunch 0000')
        nodes.name.text_value.should == 'lunch'
        nodes.time_setting.striped_value.should == '0000'
      end
    end
  end
end