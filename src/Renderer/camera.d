module s.renderer.camera;
import gl3n.frustum, gl3n.linalg;

class Camera
{
	private vec3 m_position;
	private vec3 m_forward;
	private vec3 m_up;
	
	private mat4 m_perspective;
	
	public this( vec3 position = vec3( 0.0f, 0.0f, 0.0f ), vec3 forward = vec3( 0.0f, 0.0f, -1.0f ), vec3 up = vec3( 0.0f, 1.0f, 0.0f ) )
	{
		m_position = position;
		m_forward = forward;
		m_up = up;
	}
	
	public ~this()
	{
		
	}
	
	public void Update()
	{
		// keypress shit here.
	}
	
	public void Move( const vec3 direction, float speed )
	{
		m_position += (direction * speed );
	}
	
	public void SetProjection( float fov, float width, float height, float zNear, float zFar )
	{
		m_perspective = mat4.perspective( width, height, fov, zNear, zFar );
	}
	
	public mat4 GetProjection()
	{
		return m_perspective;
	}
	
	public mat4 GetView()
	{
		return mat4.look_at( m_position, m_position + m_forward, m_up );
	}
};
