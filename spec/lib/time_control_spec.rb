# coding: utf-8

require 'spec_helper'

describe 'TimeControl' do
  context 'ao iniciar' do
    it 'deveria carregar as 100 mais usadas' do
      pending "Not yet implemented"
    end
  end
  
  context 'ao inputar uma task nova' do
    context 'com nome apenas' do
      pending "Not yet implemented"
    end
    
    context 'com horário' do
      context 'na sintaxe [+-]\d+[smhd] deveria usar o horário atual' do
        it 'adicionado/subtraído de n unidades de tempo' do
          pending "Not yet implemented"
        end
      end
      
      context 'na sintaxe \d{4}(-\d{4})?' do
        it 'deveria usar horário de início fixo' do
          pending "Not yet implemented"
        end
        
        it 'deveria usar horário de fim caso o segundo conjunto de horário seja fornecido' do
          pending "Not yet implemented"
        end
      end
    end
    
    it 'deveria exibir erro se houver erro de sintaxe' do
      pending "Not yet implemented"
    end
  end
  
  context 'ao salvar uma task' do
    it 'deveria salvar o horário como fim da task anterior' do
      pending "Not yet implemented"
    end
  end
end