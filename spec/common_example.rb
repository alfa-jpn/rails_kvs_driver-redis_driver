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

      context 'sorted_sets' do

        it 'call []' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example', 'element', 1024)
            kvs.add_sorted_set('example', 'element2', 1)

            expect(kvs.sorted_sets['example'].length).to    eq(2)
            expect(kvs.sorted_sets['example','element']).to eq(1024)
          end
        end

        it 'call []=' do
          driver_class::session(driver_config) do |kvs|
            kvs.sorted_sets['example'] = ['element', 1]
            kvs.sorted_sets['example'] = ['element2', 1]

            expect(kvs.sorted_sets['example'].length).to eq(2)
          end
        end

        it 'call count' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example', 'element', 1)
            kvs.add_sorted_set('example', 'element2', 1)

            expect(kvs.sorted_sets.count('example')).to eq(2)
          end
        end

        it 'call delete' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example', 'element', 1)
            kvs.add_sorted_set('example2', 'element2', 1)

            expect{kvs.sorted_sets.delete('example2')}.to change{kvs.sorted_sets.length}.by(-1)
          end
        end

        it 'call each' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example', 'element', 1)
            kvs.add_sorted_set('example2', 'element2', 1)

            kvs.sorted_sets.each do |key|
              expect(kvs.sorted_sets[key].length).not_to eq(0)
            end
          end
        end

        it 'call each_member' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example', 'element', 10)
            kvs.add_sorted_set('example', 'element2', 1)

            kvs.sorted_sets.each_member('example') do |member, score, position|
              expect(kvs.sorted_sets['example', member]).to eq(score)
            end
          end
        end

        it 'call has_key?' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example',  'element', 10)

            expect(kvs.sorted_sets.has_key?('example')).to      be_true
            expect(kvs.sorted_sets.has_key?('nothing key')).to  be_false
          end
        end

        it 'call has_member?' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example',  'element', 10)

            expect(kvs.sorted_sets.has_member?('example','element')).to         be_true
            expect(kvs.sorted_sets.has_member?('example','nothing member')).to  be_false
            expect(kvs.sorted_sets.has_member?('nothing key', 'element')).to    be_false
          end
        end

        it 'call increment' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example',  'element', 10)

            expect{kvs.sorted_sets.increment('example','element', 1)}.to change{kvs.sorted_sets['example','element']}.by(1)
            expect{kvs.sorted_sets.increment('example','element', -1)}.to change{kvs.sorted_sets['example','element']}.by(-1)
          end
        end

        it 'call keys' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example',  'element', 10)
            kvs.add_sorted_set('example2', 'element', 1)

            expect(kvs.sorted_sets.keys.length).to eq(2)
          end
        end

        it 'call length' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example',  'element', 10)
            kvs.add_sorted_set('example2', 'element', 1)

            expect(kvs.sorted_sets.length).to eq(2)
          end
        end

        it 'call remove' do
          driver_class::session(driver_config) do |kvs|
            kvs.add_sorted_set('example',  'element', 10)
            kvs.add_sorted_set('example', 'element', 1)

            expect{kvs.sorted_sets.remove('example', 'element')}.to change{kvs.sorted_sets.count('example')}.by(-1)
          end
        end
      end
    end
  end
end

