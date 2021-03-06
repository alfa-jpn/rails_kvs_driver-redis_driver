# How to use
# copying #{ProjectRoot}/spec
#
# require "common_example"
#
# it_should_behave_like 'RailsKvsDriver example', driver_class, driver_config
#

shared_examples_for 'RailsKvsDriver example' do |driver_class, driver_config|

  it 'inheritance RailsKvsDriver::Base' do
    expect(driver_class.ancestors.include?(RailsKvsDriver::Base)).to be_true
  end

  context 'connect kvs' do
    before(:each) do
      driver_class::session(driver_config) do |kvs|
        kvs.delete_all
      end
    end

    after(:each) do
      driver_class::session(driver_config) do |kvs|
        kvs.delete_all
      end
    end

    context 'override methods' do
      it 'call get' do
        driver_class::session(driver_config) do |kvs|
          kvs.set('example', 'nico-nico')
          expect(kvs.get('example')).to  eq('nico-nico')
          expect(kvs.get('nothing key')).to be_nil
        end
      end

      it 'call set' do
        driver_class::session(driver_config) do |kvs|
          expect{ kvs.set('example', 'nico-nico') }.to change{ kvs.keys.length }.by(1)
        end
      end

      it 'call delete' do
        driver_class::session(driver_config) do |kvs|
          kvs['example']  = 'nico-nico'
          kvs['example2'] = 'movie'

          expect{ kvs.delete('example') }.to change{ kvs.keys.length }.by(-1)

          expect(kvs.has_key?('example')).to  be_false
          expect(kvs.has_key?('example2')).to be_true
        end
      end

      it 'call delete_all' do
        driver_class::session(driver_config) do |kvs|
          kvs['example']  = 'nico-nico'
          kvs['example2'] = 'movie'

          expect{ kvs.delete_all }.to change{ kvs.keys.length }.by(-2)
        end
      end

      it 'call has_key?' do
        driver_class::session(driver_config) do |kvs|
          kvs['example'] = 'nico-nico'

          expect(kvs.has_key?('example')).to be_true
          expect(kvs.has_key?('nothing key')).to be_false
        end
      end

      it 'call keys' do
        driver_class::session(driver_config) do |kvs|
          kvs['example0'] = 'nico-nico'
          kvs['example1'] = 'nico-nico'
          kvs.add_sorted_set('example_ss', 'element5', 5)

          expect(kvs.keys.length).to eq(2)
        end
      end


      #--------------------
      # list (same as list of redis. refer to redis.)
      #--------------------

      it 'call count_list_value' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')

          expect(kvs.count_list_value('anime')).to eq(2)
        end
      end

      it 'call delete_list_value' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')
          kvs.push_list_last('anime', 'hoge')

          expect{
            kvs.delete_list_value('anime', 'hoge')
          }.to change{ kvs.count_list_value('anime') }.by(-1)
          expect(kvs.get_list_values('anime').include?('hoge')).to be_false
        end
      end

      it 'call delete_list_value_at 0' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'hoge')
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')

          expect{
            kvs.delete_list_value_at('anime', 0)
          }.to change{ kvs.count_list_value('anime') }.by(-1)
          expect(kvs.get_list_values('anime').include?('hoge')).to be_false
        end
      end

      it 'call get_list_keys' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')

          expect(kvs.get_list_keys.length).to eq(1)
        end
      end

      it 'call get_list_value' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')

          expect(kvs.get_list_value('anime', 0)).to eq('nyaruko')
        end
      end

      it 'call get_list_values' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')

          expect(kvs.get_list_values('anime').length).to eq(2)
        end
      end

      it 'call push_list_*' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')
          kvs.push_list_first('anime', 'inuhasa')

          expect(kvs.get_list_value('anime', 2)).to eq('kinmoza')
          expect(kvs.get_list_value('anime', 0)).to eq('inuhasa')
        end
      end

      it 'call pop_list_*' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')
          kvs.push_list_first('anime', 'inuhasa')

          expect{
            expect(kvs.pop_list_first('anime')).to eq('inuhasa')
            expect(kvs.pop_list_last('anime')).to eq('kinmoza')
          }.to change{ kvs.count_list_value('anime') }.by(-2)
        end
      end

      it 'call pop_list_*' do
        driver_class::session(driver_config) do |kvs|
          kvs.push_list_last('anime', 'nyaruko')
          kvs.push_list_last('anime', 'kinmoza')

          kvs.set_list_value('anime', 1, 'inuhasa')

          expect(kvs.get_list_value('anime', 1)).to eq('inuhasa')
        end
      end

      #--------------------
      # sorted set (same as sorted set of redis. refer to redis.)
      #--------------------

      it 'call add_sorted_set' do
        driver_class::session(driver_config) do |kvs|
          expect{
            kvs.add_sorted_set('example', 'element', 1)
          }.to change{ kvs.get_sorted_set_keys.length }.by(1)
        end
      end

      it 'call count_sorted_set_member' do
        driver_class::session(driver_config) do |kvs|
          kvs.add_sorted_set('example', 'element1', 5)
          kvs.add_sorted_set('example', 'element2', 5)
          kvs.add_sorted_set('example', 'element3', 5)
          expect(kvs.count_sorted_set_member('example')).to eq(3)
        end
      end

      it 'call get_sorted_set' do
        driver_class::session(driver_config) do |kvs|
          kvs.add_sorted_set('example', 'element1', 1)
          kvs.add_sorted_set('example', 'element5', 5)
          kvs.add_sorted_set('example', 'element2', 2)

          sorted_set = kvs.get_sorted_set('example')

          expect(sorted_set[0][0]).to eq('element1')
          expect(sorted_set[1][0]).to eq('element2')
          expect(sorted_set[2][0]).to eq('element5')

          expect(kvs.get_sorted_set('nothing key')).to be_nil
        end
      end

      it 'call get_sorted_set_keys' do
        driver_class::session(driver_config) do |kvs|
          kvs['example'] = 'nico-nico'
          kvs.add_sorted_set('example0_ss', 'element0', 5)
          kvs.add_sorted_set('example1_ss', 'element0', 5)

          expect(kvs.get_sorted_set_keys.length).to eq(2)
        end
      end

      it 'call get_sorted_set_score' do
        driver_class::session(driver_config) do |kvs|
          kvs.add_sorted_set('example', 'element5', 5)
          expect(kvs.get_sorted_set('example')[0][1]).to eq(5)
        end
      end

      it 'call increment_sorted_set' do
        driver_class::session(driver_config) do |kvs|
          kvs.add_sorted_set('example', 'element', 1)

          expect{
            kvs.increment_sorted_set('example', 'element', 10)
          }.to change{ kvs.get_sorted_set_score('example', 'element') }.by(10)
        end
      end

      it 'call remove_sorted_set' do
        driver_class::session(driver_config) do |kvs|
          kvs.add_sorted_set('example', 'element', 1)
          kvs.add_sorted_set('example', 'element2', 1)

          expect{
            kvs.remove_sorted_set('example', 'element')
          }.to change{ kvs.count_sorted_set_member('example') }.by(-1)
        end
      end
    end




    context 'inheritance methods' do
      it 'call []' do
        driver_class::session(driver_config) do |kvs|
          kvs['example'] = 'nico-nico'
          expect(kvs['example']).to  eq('nico-nico')
          expect(kvs['nothing key']).to be_nil
        end
      end

      it 'call []=' do
        driver_class::session(driver_config) do |kvs|
          expect{ kvs['example'] = 'nico-nico' }.to change{ kvs.keys.length }.by(1)
        end
      end

      it 'call each' do
        driver_class::session(driver_config) do |kvs|
          kvs['example0'] = 'nico-nico0'
          kvs['example1'] = 'nico-nico1'

          kvs.each do |key, value|
            expect(value).to eq(kvs[key])
          end
        end
      end

      it 'call length' do
        driver_class::session(driver_config) do |kvs|
          kvs['example0'] = 'nico-nico0'
          kvs['example1'] = 'nico-nico1'

          expect(kvs.length).to eq(2)
        end
      end

      context 'lists' do
        before(:each) do
          driver_class::session(driver_config) do |kvs|
            kvs.push_list_last('anime', 'nyaruko')
            kvs.push_list_last('anime', 'haganai')
          end
        end

        it 'call[]' do
          driver_class::session(driver_config) do |kvs|
            expect(kvs.lists['anime'].instance_of?(RailsKvsDriver::Lists::List)).to be_true
          end
        end

        it 'call []=' do
          driver_class::session(driver_config) do |kvs|

            expect{
              kvs.lists['fruit'] = [:apple, :orange]
            }.to change{
              kvs.lists.length
            }.by(1)

            expect(kvs.lists['fruit'].length).to eq(2)
          end
        end

        it 'call delete' do
          driver_class::session(driver_config) do |kvs|
            expect{kvs.lists.delete('anime')}.to change{kvs.lists.length}.by(-1)
          end
        end

        it 'call each' do
          driver_class::session(driver_config) do |kvs|
            kvs.lists.each do |key|
              expect(key).to eq('anime')
            end
          end
        end

        it 'call keys' do
          driver_class::session(driver_config) do |kvs|
            expect(kvs.lists.keys.length).to eq(1)
          end
        end

        it 'call length' do
          driver_class::session(driver_config) do |kvs|
            expect(kvs.lists.length).to eq(1)
          end
        end

        context 'lists' do
          it 'call[]' do
            driver_class::session(driver_config) do |kvs|
              expect(kvs.lists['anime'][0]).to eq('nyaruko')
            end
          end

          it 'call []=' do
            driver_class::session(driver_config) do |kvs|
              kvs.lists['anime'][1] = 'inuhasa'
              expect(kvs.lists['anime'][1]).to eq('inuhasa')
            end
          end

          it 'call delete' do
            driver_class::session(driver_config) do |kvs|
              expect{
                kvs.lists['anime'].delete('nyaruko')
              }.to change{ kvs.lists['anime'].length }.by(-1)
              expect(kvs.lists['anime'][0]).to eq('haganai')
            end
          end

          it 'call delete_at' do
            driver_class::session(driver_config) do |kvs|
              expect{
                kvs.lists['anime'].delete_at(1)
              }.to change{ kvs.lists['anime'].length }.by(-1)
              expect(kvs.lists['anime'][0]).to eq('nyaruko')
            end
          end

          it 'call each' do
            driver_class::session(driver_config) do |kvs|
              kvs.lists['anime'].each do |index, value|
                expect(kvs.lists['anime'][index]).to eq(value)
              end
            end
          end

          it 'call each' do
            driver_class::session(driver_config) do |kvs|
              kvs.lists['anime'].each do |index, value|
                expect(kvs.lists['anime'][index]).to eq(value)
              end
            end
          end

          it 'call include?' do
            driver_class::session(driver_config) do |kvs|
              expect(kvs.lists['anime'].include?('nyaruko')).to      be_true
              expect(kvs.lists['anime'].include?('konnanonaiyo')).to be_false
            end
          end

          it 'call push pop' do
            driver_class::session(driver_config) do |kvs|
              kvs.lists['anime'].push_first('rozen')
              kvs.lists['anime'].push_last('maiden')

              expect(kvs.lists['anime'].pop_first).to eq('rozen')
              expect(kvs.lists['anime'].pop_last).to  eq('maiden')
            end
          end
        end

      end


      context 'sorted_sets' do
        before(:each) do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('anime', 'nyaruko', 1024)
            kvs.add_sorted_set('anime', 'haganai', 100)
          end
        end

        it 'call []' do
          driver_class::session(driver_config) do |kvs|
            expect(kvs.sorted_sets['anime'].instance_of?(RailsKvsDriver::SortedSets::SortedSet)).to be_true
          end
        end

        it 'call []=' do
          driver_class::session(driver_config) do |kvs|

            expect{
              kvs.sorted_sets['fruit'] = [['Apple', 1], ['Orange', 2]]
            }.to change{
              kvs.sorted_sets.length
            }.by(1)

            expect(kvs.sorted_sets['fruit'].length).to eq(2)
          end
        end


        it 'call delete' do
          driver_class::session(driver_config) do |kvs|
            expect{kvs.sorted_sets.delete('anime')}.to change{kvs.sorted_sets.length}.by(-1)
          end
        end

        it 'call each' do
          driver_class::session(driver_config) do |kvs|
            kvs.sorted_sets.each do |key|
              expect(key).to eq('anime')
            end
          end
        end

        it 'call has_key?' do
          driver_class::session(driver_config) do |kvs|
            expect(kvs.sorted_sets.has_key?('anime')).to        be_true
            expect(kvs.sorted_sets.has_key?('nothing key')).to  be_false
          end
        end

        it 'call keys' do
          driver_class::session(driver_config) do |kvs|
            expect(kvs.sorted_sets.keys.length).to eq(1)
          end
        end

        it 'call length' do
          driver_class::session(driver_config) do |kvs|
            expect(kvs.sorted_sets.length).to eq(1)
          end
        end


        context 'sorted_set' do
          it 'call []' do
            driver_class::session(driver_config) do |kvs|
              expect(kvs.sorted_sets['anime']['nyaruko']).to eq(1024)
            end
          end

          it 'call []=' do
            driver_class::session(driver_config) do |kvs|
              expect{
                kvs.sorted_sets['manga']['dragonball'] = 1
              }.to change{
                kvs.sorted_sets['manga'].length
              }.by(1)

              expect{
                kvs.sorted_sets['anime']['nonnonbiyori'] = 1
              }.to change{
                kvs.sorted_sets['anime'].length
              }.by(1)
            end
          end

          it 'call each' do
            driver_class::session(driver_config) do |kvs|
              kvs.sorted_sets['anime'].each do |member, score, position|
                expect(kvs.sorted_sets['anime'][member]).to eq(score)
              end
            end
          end

          it 'call has_member?' do
            driver_class::session(driver_config) do |kvs|
              expect(kvs.sorted_sets['anime'].has_member?('nyaruko')).to         be_true
              expect(kvs.sorted_sets['anime'].has_member?('noting member')).to   be_false
            end
          end


          it 'call increment' do
            driver_class::session(driver_config) do |kvs|
              expect{kvs.sorted_sets['anime'].increment('nyaruko',  1)}.to change{kvs.sorted_sets['anime']['nyaruko']}.by(1)
              expect{kvs.sorted_sets['anime'].increment('nyaruko', -1)}.to change{kvs.sorted_sets['anime']['nyaruko']}.by(-1)
            end
          end

          it 'call length' do
            driver_class::session(driver_config) do |kvs|
              expect(kvs.sorted_sets['anime'].length).to eq(2)
            end
          end

          it 'call members' do
            driver_class::session(driver_config) do |kvs|
              expect(kvs.sorted_sets['anime'].members.length).to eq(2)
            end
          end

          it 'call remove' do
            driver_class::session(driver_config) do |kvs|
              expect{
                kvs.sorted_sets['anime'].remove('haganai')
              }.to change{
                kvs.sorted_sets['anime'].length
              }.by(-1)
            end
          end

        end

      end
    end
  end
end

