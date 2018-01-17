const UserSummary = ({id, username, twitter_user_url, status_count, most_recent_status}) => (
	<div>
		<h1 className="display-4">{username}</h1>
		<table className="table">
		  <tbody>
		    <tr>
		      <th style={{width:'15%'}}>id</th>
		      <td>{id}</td>
		    </tr>
		    <tr>
		      <th>twitter user</th>
		      <td>
		      	<a href={twitter_user_url}>{twitter_user_url.replace('https://twitter.com/','')}</a>
		      </td>
		    </tr>
		    <tr>
		      <th>status count</th>
		      <td>{status_count}</td>
		    </tr>
		    <tr>
		      <th>most recent status</th>
		      <td>
		      	<a href={most_recent_status}>{most_recent_status.replace('https://twitter.com/','')}</a>
		      </td>
		    </tr>
		  </tbody>
		</table>
	</div>
)