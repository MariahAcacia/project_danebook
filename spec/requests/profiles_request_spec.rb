require 'rails_helper'

describe 'ProfilesRequests' do

  let(:user){ create(:user) }
  let(:another_user){ create(:user) }

  describe 'User Access' do

    describe 'GET #show' do

      it 'works as normal if signed in' do
        profile = create(:profile, user_id: user.id)
        post session_path, params: { email: user.email, password: user.password }
        get user_profile_path(user)
        expect(response).to be_success
      end
    end

    describe 'GET #edit' do

      before :each do
        profile = create(:profile, user_id: user.id)
        post session_path, params: { email: user.email, password: user.password }
      end

      it 'works as normal when logged in' do
        get edit_user_profile_path(user)
        expect(response).to be_success
      end
      it 'for another user redirects to owns profile to edit' do
        other_user = create(:user)
        get edit_user_profile_path(other_user)
        expect(response).to have_http_status(:redirect)
      end

    end


    describe 'PATCH #update' do

      before :each do
        user
        another_user
        post session_path, params: { email: user.email, password: user.password }
        allow_any_instance_of(ApplicationController).to receive(:find_current_page_user).and_return(user)
      end

      context 'with valid attributes' do

        let(:users_profile){ create(:profile, user_id: user.id) }
        let(:words_this_guy_lives_by){ "Jo Mama" }

        before :each do
          patch user_profile_path(users_profile.user_id), params: { profile: attributes_for(:profile, words_to_live_by: words_this_guy_lives_by)}
        end

        it 'actually updates profile' do
          users_profile.reload
          expect(users_profile.words_to_live_by).to eq(words_this_guy_lives_by)
        end

        it 'redirects back to profile if successful' do
          users_profile.reload
          expect(response).to have_http_status(:redirect)
        end

        it 'creates flash message' do
          expect(flash[:success]).to_not be_nil
        end
      end

      context 'with invalid attributes' do

        before do
          user
        end

        let(:users_profile){ create(:profile, user_id: user.id) }
        let(:new_bday){ nil }

        it 'does not update attributes' do
          patch user_profile_path(users_profile.user_id), params: { profile: attributes_for(:profile, birthday: new_bday) }
          expect(users_profile.birthday).to eq(user.profile.birthday)
        end

        it 'creates flash message' do
          patch user_profile_path(users_profile.user_id), params: { profile: attributes_for(:profile, birthday: nil) }
          expect(flash[:danger]).to_not be_nil
        end

        it 're-renders form' do
          patch user_profile_path(users_profile.user_id), params: { profile: attributes_for(:profile, birthday: nil) }
          expect(response).to render_template(:edit)
        end

      end

      context 'for another user' do

        let(:another_profile){ create(:profile, user_id: another_user.id) }

        before do
          another_user
          another_profile
        end 

        it 'does not allow you to update' do
          patch user_profile_path(another_profile.user_id), params: { profile: attributes_for(:profile) }
          expect(response).to_not be_success
        end

        it 'creates flash message and redirects back to profile' do
          patch user_profile_path(another_profile.user_id), params: { profile: attributes_for(:profile) }
          expect(flash[:danger]).not_to be_nil
          expect(response).to redirect_to user_profile_path(another_user)
        end

      end

    end

  end

  describe 'Non-User Access' do

    describe 'GET #show' do

      before :each do
        get user_profile_path(user)
      end

      it 'is not successful' do
        expect(response).to_not be_success
      end

      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end

      it 'creates flash message' do
        expect(flash[:danger]).to_not be_nil
      end
    end

    describe 'GET #edit' do
      before :each do
        get edit_user_profile_path(user)
      end

      it 'is not successful' do
        expect(response).to_not be_success
      end

      it 'redirects to root_path' do
        expect(response).to redirect_to root_path
      end

      it 'creates flash message' do
        expect(flash[:danger]).to_not be_nil
      end
    end

    describe 'PATCH #update' do

      before :each do
        patch user_profile_path(user), params: { profile: attributes_for(:profile)}
      end

      it 'is not successful' do
        expect(response).to_not be_success
      end

      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end

      it 'creates flash message' do
        expect(flash[:danger]).to_not be_nil
      end
    end
  end

end
