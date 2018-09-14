package jungbeen.note.user.service;

import java.util.List;

import jungbeen.note.user.domain.User;

public interface UserService {
	User findUser(String userId);         //사용자 한명 조회
	List<User> findIds(String userName);  //사용자 아이디 조회
	boolean join(User user);              //사용자 등록
	boolean updateName(User user);        //사용자 이름 변경
	boolean updatePw(User user);          //사용자 비밀번호 변경
	boolean updateEmail(User user);       //사용자 이메일 변경
	boolean delUser(User user);       //사용자 삭제
}