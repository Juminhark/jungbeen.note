package jungbeen.note.usernote.domain;

public class UserNote {
	private String userId;
	private int noteId;
	private int noteIdx;
	private int isOwner; //1 true 0 false
	
	public UserNote() {
		/*
		 * int의 init값은 0 인데, noteIdx와 isOwner는 0을 값으로 가질 수 있다.
		 * 따라서 이 두 field에 값이 입력되었는지 확인할 수 없으므로
		 * -1을 초기값으로 지정한다.
		 */
		this.noteIdx = -1;
		this.isOwner = -1;
	}
	
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public int getNoteId() {
		return noteId;
	}
	public void setNoteId(int noteId) {
		this.noteId = noteId;
	}
	public int getNoteIdx() {
		return noteIdx;
	}
	public void setNoteIdx(int noteIdx) {
		this.noteIdx = noteIdx;
	}
	public int getIsOwner() {
		return isOwner;
	}
	public void setIsOwner(int isOwner) {
		this.isOwner = isOwner;
	}
}
