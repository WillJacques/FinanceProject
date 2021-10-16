module Enumerable
  def mean
    return nil if empty?

    sum / size.to_f
  end

  def sample_variance
    return nil if empty?

    m = mean
    sum = inject(0) { |accum, i| accum + (i - m)**2 }
    sum / (length - 1).to_f
  end

  def standard_deviation
    return nil if empty?

    Math.sqrt(sample_variance)
  end

  def variation
    return nil if empty?

    (last - first) / first
  end

  def coefficent_of_variation
    return nil if size != 2

    size = first.size
    mean1 = first.mean
    mean2 = second.mean

    array_merge = [first, second].transpose

    cov_sum = 0
    array_merge.each do |item|
      cov_sum += (item[0].to_f - mean1) * (item[1].to_f - mean2)
    end
    cov = cov_sum / (size - 1)
    cov.round(6)
  end

  def multiply_matrix
    return nil if size != 2

    result = Array.new(first.size) { Array.new(second.first.size) { 0 } }

    (0..result.size - 1).each do |i|
      (0..result.first.size - 1).each do |j|
        (0..first.first.size - 1).each do |k|
          result[i][j] += first[i][k] * second[k][j]
        end
      end
    end
    result
  end

  def pearson_correlation
    return nil if size != 2

    array_merge = [first, second].transpose

    sum1 = sum2 = moy1 = moy2 = sum1_sq = sum2_sq = psum = 0

    array_merge.each do |item|
      sum1 += item[0].to_f
      sum2 += item[1].to_f

      moy1 = sum1 / first.size
      moy2 = sum2 / second.size

      sum1_sq += item[0].to_f**2
      sum2_sq += item[1].to_f**2

      psum += item[0].to_f * item[1].to_f
    end

    num = (n * psum) - (sum1 * sum2)
    den = (((n * sum1_sq) - sum1**2)**0.5) * (((n * sum2_sq) - sum2**2)**0.5)

    cc = den.zero? ? 0 : num / den

    cc.round(6)
  end

  def correlation
    return nil if size != 2

    array_merge = [first, second].transpose

    sum1_sq = sum2_sq = psum = 0

    mean1 = first.mean
    mean2 = second.mean

    array_merge.each do |item|
      a = item[0].to_f - mean1
      b = item[1].to_f - mean2

      sum1_sq += a**2
      sum2_sq += b**2

      psum += a * b
    end

    num = psum
    den = (sum1_sq * sum2_sq)**0.5

    cc = den.zero? ? 0 : num / den

    cc.round(6)
  end
end
