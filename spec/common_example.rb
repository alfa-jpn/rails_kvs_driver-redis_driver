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

    it 'call set value' do
      driver_class::session(driver_config) do |kvs|
        expect{ kvs['example'] = 'nico-nico' }.to change{ kvs.all_keys.length }.by(1)
      end
    end

    it 'call get value' do
      driver_class::session(driver_config) do |kvs|
        expect{ kvs['example'] = 'nico-nico' }.to change{ kvs.all_keys.length }.by(1)
        expect(kvs['example']).to eq('nico-nico')
      end
    end

    it 'call all keys' do
      driver_class::session(driver_config) do |kvs|
        expect{ kvs['example'] = 'nico-nico' }.to change{ kvs.all_keys.length }.by(1)
        expect(kvs.all_keys.length).to eq(1)
      end
    end

    it 'call delete value' do
      driver_class::session(driver_config) do |kvs|
        kvs['example']  = 'nico-nico'
        kvs['example2'] = 'movie'

        expect{ kvs.delete('example') }.to change{ kvs.all_keys.length }.by(-1)

        expect(kvs['example']).to eq(nil)
        expect(kvs['example2']).to eq('movie')
      end
    end

    it 'call delete_all' do
      driver_class::session(driver_config) do |kvs|
        kvs['example']  = 'nico-nico'
        kvs['example2'] = 'movie'

        expect{ kvs.delete_all }.to change{ kvs.all_keys.length }.by(-2)

        expect(kvs['example']).to   eq(nil)
        expect(kvs['example2']).to  eq(nil)
      end
    end

    it 'call add_sorted_set' do
      driver_class::session(driver_config) do |kvs|
        expect{
          kvs.add_sorted_set('example', 'element', 1)
        }.to change{ kvs.all_keys.length }.by(1)
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

    it 'call increment_sorted_set' do
      driver_class::session(driver_config) do |kvs|
        kvs.add_sorted_set('example', 'element', 1)

        expect{
          kvs.increment_sorted_set('example', 'element', 10)
        }.to change{ kvs.sorted_set_score('example', 'element') }.by(10)
      end
    end

    it 'call sorted_set' do
      driver_class::session(driver_config) do |kvs|
        kvs.add_sorted_set('example', 'element1', 1)
        kvs.add_sorted_set('example', 'element5', 5)
        kvs.add_sorted_set('example', 'element2', 2)

        sorted_set = kvs.sorted_set('example')

        expect(sorted_set[0][0]).to eq('element1')
        expect(sorted_set[1][0]).to eq('element2')
        expect(sorted_set[2][0]).to eq('element5')
      end
    end

    it 'call sorted_set_score' do
      driver_class::session(driver_config) do |kvs|
        kvs.add_sorted_set('example', 'element5', 5)
        expect(kvs.sorted_set('example')[0][1]).to eq(5)
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
  end
end

