require 'rails_helper'

describe Login do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value('test@example.com').for(:email) }
  it { is_expected.to_not allow_value('test_example.com').for(:email) }

  it 'validates presence of either password or Facebook UID' do
    login = described_class.new(email: 'test@example.com', oauth2_token: 'token')

    expect(login).to_not be_valid
  end

  it "doesn't validate presence of password when Facebook UID is present" do
    login = described_class.new(email: 'test@example.com', oauth2_token: 'token', facebook_uid: '123')

    expect(login).to be_valid
  end

  it "doesn't validate presence of Facebook UID  when password is present" do
    login = described_class.new(email: 'test@example.com', oauth2_token: 'token', password: '123')

    expect(login).to be_valid
  end

  describe '#refresh_oauth2_token!' do
    subject { described_class.new(oauth2_token: 'oldtoken') }

    before do
      allow(subject).to receive(:save!)
    end

    it 'force-resets oauth2 token' do
      expect { subject.refresh_oauth2_token! }.to change(subject, :oauth2_token)
    end

    it 'saves the model' do
      expect(subject).to receive(:save!)

      subject.refresh_oauth2_token!
    end
  end

  describe '#verified?' do
    it 'is true when verified_at is not in the future' do
      expect(described_class.new(verified_at: Time.zone.now)).to be_verified
    end

    it 'is false when verified_at is in the future' do
      expect(described_class.new(verified_at: 1.hour.from_now)).to_not be_verified
    end

    it 'is false when verified_at is blank' do
      expect(described_class.new).to_not be_verified
    end
  end

  describe '#verify!' do
    subject { create(:login) }

    context 'when the account is already verified' do
      it 'raises an AlreadyVerifiedError' do
        subject.verify!

        expect { subject.verify! }.to raise_error(Login::AlreadyVerifiedError)
      end
    end

    context 'when the account is not verified' do
      it 'sets verified_at to the current time' do
        Timecop.freeze do
          expect { subject.verify! }.to change(subject, :verified_at).from(nil).to(Time.zone.now)
        end
      end
    end
  end
end
