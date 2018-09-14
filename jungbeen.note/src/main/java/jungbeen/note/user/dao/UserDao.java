package jungbeen.note.user.dao;

import java.util.List;

import jungbeen.note.user.domain.User;

public interface UserDao {
	User getUser(String userId);          //사용자 한명 정보 조회
	List<User> getIds(String userName);   //사용자 아이디 조회
	int addUser(User user);               //사용자 정보 추가
	int updateName(User user);            //사용자 이름 변경
	int updatePw(User user);              //사용자 비밀번호 변경
	int updateEmail(User user);           //사용자 이메일 변경
	int delUser(User user);           //사용자 삭제
}
