# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::RSpec::DescribedClass do
  subject(:cop) { described_class.new }

  it 'checks for the use of the described class' do
    inspect_source(cop, ['describe MyClass do',
                         '  subject { MyClass.do_something }',
                         '  before { MyClass.do_something }',
                         'end'])
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses.map(&:line).sort).to eq([2, 3])
    expect(cop.messages)
      .to eq(['Use `described_class` instead of `MyClass`'] * 2)
    expect(cop.highlights).to eq(['MyClass'] * 2)
  end

  it 'ignores described class as string' do
    inspect_source(cop, ['describe MyClass do',
                         '  subject { "MyClass" }',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores describes that do not referece to a class' do
    inspect_source(cop, ['describe "MyClass" do',
                         '  subject { "MyClass" }',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores if the scope is changing' do
    inspect_source(cop, ['describe MyClass do',
                         '  include MyClass',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([2])
    expect(cop.messages)
      .to eq(['Use `described_class` instead of `MyClass`'])
    expect(cop.highlights).to eq(['MyClass'])
  end

  it 'ignores class if the scope is changing' do
    inspect_source(cop, ['describe MyClass do',
                         '  def method',
                         '    include MyClass',
                         '  end',
                         '  class OtherClass',
                         '    include MyClass',
                         '  end',
                         '  module MyModle',
                         '    include MyClass',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'only takes class from top level describes' do
    inspect_source(cop, ['describe MyClass do',
                         '  describe MyClass::Foo do',
                         '    subject { MyClass::Foo }',
                         '    let(:foo) { MyClass }',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([4])
    expect(cop.messages)
      .to eq(['Use `described_class` instead of `MyClass`'])
    expect(cop.highlights).to eq(['MyClass'])
  end

  it 'ignores subclasses' do
    inspect_source(cop, ['describe MyClass do',
                         '  subject { MyClass::SubClass }',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores if namespace is not matching' do
    inspect_source(cop, ['describe MyNamespace::MyClass do',
                         '  subject { ::MyClass }',
                         '  let(:foo) { MyClass }',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'checks for the use of described class with namespace' do
    inspect_source(cop, ['describe MyNamespace::MyClass do',
                         '  subject { MyNamespace::MyClass }',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([2])
    expect(cop.messages)
      .to eq(['Use `described_class` instead of `MyNamespace::MyClass`'])
    expect(cop.highlights).to eq(['MyNamespace::MyClass'])
  end

  it 'checks for the use of described class with module' do
    pending 'TODO'
    inspect_source(cop, ['module MyNamespace',
                         '  describe MyClass do',
                         '    subject { MyNamespace::MyClass }',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([2])
    expect(cop.messages)
      .to eq(['Use `described_class` instead of `MyNamespace::MyClass`'])
    expect(cop.highlights).to eq(['MyNamespace::MyClass'])
  end
end