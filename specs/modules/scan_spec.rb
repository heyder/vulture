require_relative '../../modules/scan'


describe RotScanner do
    context 'initialize' do
        it 'instance variable' do
            expect( RotScanner.new ).to be_instance_of(RotScanner)
        end
        it 'invalid scan type should raise an exception' do
            expect{ RotScanner.new( {:rot => 'invalid' } ) }.to raise_error(RuntimeError)
        end
    end
end