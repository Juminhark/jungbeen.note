package jungbeen.note.page.domain;

public class Page {
	private int noteId;
	private int id;
	private int idx;
	private String content1;
	private String content2;
	private String content3;
	private String content4;
	private String content5;
	
	public Page() {
		idx = -1;
	}
	
	public int getNoteId() {
		return noteId;
	}
	public void setNoteId(int noteId) {
		this.noteId = noteId;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getIdx() {
		return idx;
	}
	public void setIdx(int idx) {
		this.idx = idx;
	}
	public String getContent1() {
		return content1;
	}
	public void setContent1(String content1) {
		this.content1 = content1;
	}
	public String getContent2() {
		return content2;
	}
	public void setContent2(String content2) {
		this.content2 = content2;
	}
	public String getContent3() {
		return content3;
	}
	public void setContent3(String content3) {
		this.content3 = content3;
	}
	public String getContent4() {
		return content4;
	}
	public void setContent4(String content4) {
		this.content4 = content4;
	}
	public String getContent5() {
		return content5;
	}
	public void setContent5(String content5) {
		this.content5 = content5;
	}
}
