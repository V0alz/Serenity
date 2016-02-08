module s.renderer.chunkData;
import std.container, std.conv : to;
import gl3n.linalg : vec3;

struct ChunkData
{
	public Array!vec3 m_vertex;
	public Array!vec3 m_normal;
	public Array!vec3 m_color;
	public Array!int m_indices;
	
	public int AddVertex( vec3 v, vec3 n, vec3 c )
	{
		m_vertex.insertBack( v );
		m_normal.insertBack( n );
		m_color.insertBack( c );
		
		return m_vertex.length();
	}
	
	public void AddFace( vec3 face )
	{
		m_indices.insertBack( to!uint(face.x) );
		m_indices.insertBack( to!uint(face.y) );
		m_indices.insertBack( to!uint(face.z) );
	}
};
