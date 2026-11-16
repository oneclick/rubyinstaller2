#frozen_string_literal: true
require "minitest/autorun"

class TestJit < Minitest::Test
  if RUBY_VERSION =~ /^4\.[12]\./
    # Verify ruby-4.1+ is provided with YJIT

    def test_yjit_is_supported
      assert defined?(RubyVM::YJIT),
        "RubyVM::YJIT is not defined; this Ruby binary was built without YJIT support."
      assert_respond_to RubyVM::YJIT, :enable
    end

    def test_yjit_can_be_enabled
      skip "RubyVM::YJIT is not supported in this build" unless defined?(RubyVM::YJIT)

      RubyVM::YJIT.enable unless RubyVM::YJIT.enabled?
      assert RubyVM::YJIT.enabled?, "Expected RubyVM::YJIT.enabled? to return true after enabling."
    end

    def test_yjit_compiles_hot_code
      skip "RubyVM::YJIT is not supported in this build" unless defined?(RubyVM::YJIT)
      RubyVM::YJIT.enable unless RubyVM::YJIT.enabled?

      iseq_count_before = RubyVM::YJIT.runtime_stats(:compiled_iseq_count)
      compile_time_before = RubyVM::YJIT.total_compile_time_ns

      # Execute a freshly defined method past YJIT's default call threshold (30 calls)
      target = Object.new
      target.define_singleton_method(:compute) { |n| (n * 3) + 7 }

      sum = 0
      100.times { |i| sum += target.compute(i) }
      assert_equal 15_550, sum

      iseq_count_after = RubyVM::YJIT.runtime_stats(:compiled_iseq_count)
      compile_time_after = RubyVM::YJIT.total_compile_time_ns

      assert_operator compile_time_after, :>, compile_time_before,
          "Expected RubyVM::YJIT.total_compile_time_ns to increase after hot loop."
      assert_operator iseq_count_after, :>, iseq_count_before,
          "Expected :compiled_iseq_count to increase (before: #{iseq_count_before}, after: #{iseq_count_after})."
    end

  else
    # Ruby < 4.1 has no JIT

    def test_no_jit_support_before_ruby_4_1
      refute defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?,
          "Expected Ruby #{RUBY_VERSION} (< 4.1) to have no active YJIT support."
      refute defined?(RubyVM::YJIT),
          "Expected RubyVM::YJIT not to be defined on Ruby #{RUBY_VERSION} (< 4.1)."
    end
  end
end
