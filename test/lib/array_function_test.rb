require 'test_helper'

class StatisticsTest < ActiveSupport::TestCase
  ARRAY = [1, 2, 2.2, 2.3, 4, 5].freeze

  test '#sum' do
    assert_equal 16.5, ARRAY.sum
  end

  test '#mean' do
    assert_equal 2.75, ARRAY.mean
  end

  test '#sample_variance' do
    assert_equal 2.151, ARRAY.sample_variance
  end

  test '#standard_deviation' do
    assert_equal 1.466628787389638, ARRAY.standard_deviation
  end

  test '#variation' do
    assert_equal 4, ARRAY.variation
  end

  test '#correlation' do
    array1 = [1691.75, 1977.80, 1884.09, 2151.13, 2519.36]
    array2 = [68.96, 100.11, 109.06, 112.18, 154.12]
    assert_equal 0.954705, [array1, array2].correlation
  end
end
